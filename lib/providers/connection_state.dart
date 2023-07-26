import 'package:riverpod/src/stream_provider.dart';

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
AutoDisposeStreamProvider<ConnectionState> globalConnectionStateProvider = globalConnectionState.provider();
