import 'package:flutter_riverpod/flutter_riverpod.dart';

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
AutoDisposeStreamProvider<ConnectionState> globalConnectionStateProvider =
    globalConnectionState.provider();
