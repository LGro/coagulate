import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final globalConnectionState =
    StateController<GlobalConnectionState>(GlobalConnectionState.detached);
final globalConnectionStateProvider = StateNotifierProvider<
    StateController<GlobalConnectionState>,
    GlobalConnectionState>((ref) => globalConnectionState);
