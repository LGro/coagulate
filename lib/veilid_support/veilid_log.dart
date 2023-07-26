import 'package:flutter/foundation.dart';
import 'package:loggy/loggy.dart';
import 'package:veilid/veilid.dart';

import '../log/loggy.dart';

VeilidConfigLogLevel convertToVeilidConfigLogLevel(LogLevel? level) {
  if (level == null) {
    return VeilidConfigLogLevel.off;
  }
  switch (level) {
    case LogLevel.error:
      return VeilidConfigLogLevel.error;
    case LogLevel.warning:
      return VeilidConfigLogLevel.warn;
    case LogLevel.info:
      return VeilidConfigLogLevel.info;
    case LogLevel.debug:
      return VeilidConfigLogLevel.debug;
    case traceLevel:
      return VeilidConfigLogLevel.trace;
  }
  return VeilidConfigLogLevel.off;
}

void setVeilidLogLevel(LogLevel? level) {
  Veilid.instance.changeLogLevel('all', convertToVeilidConfigLogLevel(level));
}

class VeilidLoggy implements LoggyType {
  @override
  Loggy<VeilidLoggy> get loggy => Loggy<VeilidLoggy>('Veilid');
}

Loggy get _veilidLoggy => Loggy<VeilidLoggy>('Veilid');

Future<void> processLog(VeilidLog log) async {
  StackTrace? stackTrace;
  Object? error;
  final backtrace = log.backtrace;
  if (backtrace != null) {
    stackTrace =
        StackTrace.fromString('$backtrace\n${StackTrace.current}');
    error = 'embedded stack trace for ${log.logLevel} ${log.message}';
  }

  switch (log.logLevel) {
    case VeilidLogLevel.error:
      _veilidLoggy.error(log.message, error, stackTrace);
      break;
    case VeilidLogLevel.warn:
      _veilidLoggy.warning(log.message, error, stackTrace);
      break;
    case VeilidLogLevel.info:
      _veilidLoggy.info(log.message, error, stackTrace);
      break;
    case VeilidLogLevel.debug:
      _veilidLoggy.debug(log.message, error, stackTrace);
      break;
    case VeilidLogLevel.trace:
      _veilidLoggy.trace(log.message, error, stackTrace);
      break;
  }
}

void initVeilidLog() {
  const isTrace = String.fromEnvironment('logTrace') != '';
  LogLevel logLevel;
  if (isTrace) {
    logLevel = traceLevel;
  } else {
    logLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  }
  setVeilidLogLevel(logLevel);
}
