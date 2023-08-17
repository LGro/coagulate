import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tools/tools.dart';

enum GlobalConnectionState {
  detached,
  detaching,
  attaching,
  attachedWeak,
  attachedGood,
  attachedStrong,
  fullyAttached,
  overAttached,
}

ExternalStreamState<GlobalConnectionState> globalConnectionState =
    ExternalStreamState<GlobalConnectionState>(GlobalConnectionState.detached);
AutoDisposeStreamProvider<GlobalConnectionState> globalConnectionStateProvider =
    globalConnectionState.provider();
