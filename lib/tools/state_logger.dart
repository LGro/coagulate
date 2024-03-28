import 'package:bloc/bloc.dart';
import 'package:loggy/loggy.dart';
import 'loggy.dart';

const Map<String, LogLevel> _blocChangeLogLevels = {
  'ConnectionStateCubit': LogLevel.off,
  'ActiveConversationMessagesBlocMapCubit': LogLevel.off
};
const Map<String, LogLevel> _blocCreateCloseLogLevels = {};
const Map<String, LogLevel> _blocErrorLogLevels = {};

/// [BlocObserver] for the VeilidChat application that
/// observes all state changes.
class StateLogger extends BlocObserver {
  /// {@macro counter_observer}
  const StateLogger();

  void _checkLogLevel(
      Map<String, LogLevel> blocLogLevels,
      LogLevel defaultLogLevel,
      BlocBase<dynamic> bloc,
      void Function(LogLevel) closure) {
    final logLevel =
        blocLogLevels[bloc.runtimeType.toString()] ?? defaultLogLevel;
    if (logLevel != LogLevel.off) {
      closure(logLevel);
    }
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _checkLogLevel(_blocChangeLogLevels, LogLevel.debug, bloc, (logLevel) {
      log.log(logLevel, 'Change: ${bloc.runtimeType} $change');
    });
  }

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    _checkLogLevel(_blocCreateCloseLogLevels, LogLevel.debug, bloc, (logLevel) {
      log.log(logLevel, 'Create: ${bloc.runtimeType}');
    });
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    _checkLogLevel(_blocCreateCloseLogLevels, LogLevel.debug, bloc, (logLevel) {
      log.log(logLevel, 'Close: ${bloc.runtimeType}');
    });
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _checkLogLevel(_blocErrorLogLevels, LogLevel.error, bloc, (logLevel) {
      log.log(logLevel, 'Error: ${bloc.runtimeType} $error\n$stackTrace');
    });
  }
}
