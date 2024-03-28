import 'package:loggy/loggy.dart';
import 'package:meta/meta.dart';
import 'package:veilid/veilid.dart';

// Loggy tools
const LogLevel traceLevel = LogLevel('Trace', 1);

extension TraceLoggy on Loggy {
  void trace(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      log(traceLevel, message, error, stackTrace);
}

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

void changeVeilidLogIgnore(String change) {
  Veilid.instance.changeLogIgnore('all', change.split(','));
}

class VeilidLoggy implements LoggyType {
  @override
  Loggy<VeilidLoggy> get loggy => Loggy<VeilidLoggy>('Veilid');
}

@internal
Loggy get veilidLoggy => Loggy<VeilidLoggy>('Veilid');

void processLog(VeilidLog log) {
  StackTrace? stackTrace;
  Object? error;
  final backtrace = log.backtrace;
  if (backtrace != null) {
    stackTrace = StackTrace.fromString('$backtrace\n${StackTrace.current}');
    error = 'embedded stack trace for ${log.logLevel} ${log.message}';
  }

  switch (log.logLevel) {
    case VeilidLogLevel.error:
      veilidLoggy.error(log.message, error, stackTrace);
      break;
    case VeilidLogLevel.warn:
      veilidLoggy.warning(log.message, error, stackTrace);
      break;
    case VeilidLogLevel.info:
      veilidLoggy.info(log.message, error, stackTrace);
      break;
    case VeilidLogLevel.debug:
      veilidLoggy.debug(log.message, error, stackTrace);
      break;
    case VeilidLogLevel.trace:
      veilidLoggy.trace(log.message, error, stackTrace);
      break;
  }
}

void initVeilidLog(bool debugMode) {
  // ignore: do_not_use_environment
  const isTrace = String.fromEnvironment('LOG_TRACE') != '';
  LogLevel logLevel;
  if (isTrace) {
    logLevel = traceLevel;
  } else {
    logLevel = debugMode ? LogLevel.debug : LogLevel.info;
  }
  setVeilidLogLevel(logLevel);
}
