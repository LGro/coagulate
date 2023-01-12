import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:loggy/loggy.dart';
import 'package:ansicolor/ansicolor.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Loggy tools
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

extension PrettyPrintLogRecord on LogRecord {
  String pretty() {
    final lstr =
        wrapWithLogColor(level, '[${level.toString().substring(0, 1)}]');
    return '$lstr $message';
  }
}

class CallbackPrinter extends LoggyPrinter {
  CallbackPrinter() : super();

  void Function(LogRecord)? callback;

  @override
  void onLog(LogRecord record) {
    debugPrint(record.pretty());
    callback?.call(record);
  }

  void setCallback(Function(LogRecord)? cb) {
    callback = cb;
  }
}

var globalTerminalPrinter = CallbackPrinter();

extension TraceLoggy on Loggy {
  void trace(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      this.log(traceLevel, message, error, stackTrace);
}

LogOptions getLogOptions(LogLevel? level) {
  return LogOptions(
    level ?? LogLevel.all,
    stackTraceLevel: LogLevel.error,
  );
}

class RootLoggy implements LoggyType {
  @override
  Loggy<RootLoggy> get loggy => Loggy<RootLoggy>('');
}

Loggy get log => Loggy<RootLoggy>('veilidchat');

void initLoggy() {
  Loggy.initLoggy(
    logPrinter: globalTerminalPrinter,
    logOptions: getLogOptions(null),
  );

  const isTrace = String.fromEnvironment("logTrace", defaultValue: "") != "";
  LogLevel logLevel;
  if (isTrace) {
    logLevel = traceLevel;
  } else {
    logLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  }

  Loggy('').level = getLogOptions(logLevel);
}
