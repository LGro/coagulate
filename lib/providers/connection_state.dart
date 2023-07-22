import '../tools/tools.dart';

enum ConnectionState {
  detached,
  detaching,
  attaching,
  attachedWeak,
  attachedGood,
  attachedStrong,
  fullyAttached,
  overAttached,
}

ExternalStreamState<ConnectionState> globalConnectionState =
    ExternalStreamState<ConnectionState>(ConnectionState.detached);
var globalConnectionStateProvider = globalConnectionState.provider();
