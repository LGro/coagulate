import 'dart:io' show Platform;

import 'package:ansicolor/ansicolor.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:loggy/loggy.dart';

import '../debug_log.dart';
import 'state_logger.dart';

const LogLevel traceLevel = LogLevel('Trace', 1);

String wrapWithLogColor(LogLevel? level, String text) {
  // XXX: https://github.com/flutter/flutter/issues/64491
  if (!kIsWeb && Platform.isIOS) {
    return text;
  }

  if (level == null) {
    return text;
  }
  final pen = AnsiPen();
  ansiColorDisabled = false;
  switch (level) {
    case LogLevel.error:
      pen
        ..reset()
        ..red(bold: true);
      return pen(text);
    case LogLevel.warning:
      pen
        ..reset()
        ..yellow(bold: true);
      return pen(text);
    case LogLevel.info:
      pen
        ..reset()
        ..white(bold: true);
      return pen(text);
    case LogLevel.debug:
      pen
        ..reset()
        ..green(bold: true);
      return pen(text);
    case traceLevel:
      pen
        ..reset()
        ..blue(bold: true);
      return pen(text);
  }
  return text;
}

final DateFormat _dateFormatter = DateFormat('HH:mm:ss.SSS');

extension PrettyPrintLogRecord on LogRecord {
  String pretty() {
    final tm = _dateFormatter.format(time.toLocal());
    final lev = logLevelEmoji(level);
    final lstr = wrapWithLogColor(level, tm);
    return '$lstr $lev $message';
  }
}

List<LogLevel> logLevels = [
  LogLevel.error,
  LogLevel.warning,
  LogLevel.info,
  LogLevel.debug,
  traceLevel,
];

String logLevelName(LogLevel logLevel) {
  switch (logLevel) {
    case traceLevel:
      return 'TRACE';
    case LogLevel.debug:
      return 'DEBUG';
    case LogLevel.info:
      return 'INFO';
    case LogLevel.warning:
      return 'WARNING';
    case LogLevel.error:
      return 'ERROR';
  }
  return '???';
}

String logLevelEmoji(LogLevel logLevel) {
  switch (logLevel) {
    case traceLevel:
      return '👾';
    case LogLevel.debug:
      return '🐛';
    case LogLevel.info:
      return '💡';
    case LogLevel.warning:
      return '🍋';
    case LogLevel.error:
      return '🛑';
  }
  return '❓';
}

class CallbackPrinter extends LoggyPrinter {
  CallbackPrinter() : super();

  void Function(LogRecord)? callback;

  @override
  void onLog(LogRecord record) {
    final out = record.pretty().replaceAll('\uFFFD', '');

    if (!kIsWeb && Platform.isAndroid) {
      debugPrint(out);
    } else {
      debugPrintSynchronously(out);
    }
    // DebugLogger().log(out);
    callback?.call(record);
  }

  // Change callback function
  // ignore: use_setters_to_change_properties
  void setCallback(void Function(LogRecord)? cb) {
    callback = cb;
  }
}

CallbackPrinter globalTerminalPrinter = CallbackPrinter();

LogOptions getLogOptions(LogLevel? level) => LogOptions(
      level ?? LogLevel.all,
      stackTraceLevel: LogLevel.error,
    );

class RootLoggy implements LoggyType {
  @override
  Loggy<RootLoggy> get loggy => Loggy<RootLoggy>('');
}

Loggy get log => Loggy<RootLoggy>('coagulate');

void initLoggy() {
  Loggy.initLoggy(
    logPrinter: globalTerminalPrinter,
    logOptions: getLogOptions(null),
  );

  // ignore: do_not_use_environment
  const isTrace = String.fromEnvironment('LOG_TRACE') != '';
  LogLevel logLevel;
  if (isTrace) {
    logLevel = traceLevel;
  } else {
    logLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  }

  Loggy('').level = getLogOptions(logLevel);

  // Create state logger
  Bloc.observer = const StateLogger();
}
