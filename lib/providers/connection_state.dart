import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../veilid_support/veilid_support.dart';

part 'connection_state.freezed.dart';

@freezed
class ConnectionState with _$ConnectionState {
  const factory ConnectionState({
    required VeilidStateAttachment attachment,
  }) = _ConnectionState;
  const ConnectionState._();

  bool get isAttached => !(attachment.state == AttachmentState.detached ||
      attachment.state == AttachmentState.detaching ||
      attachment.state == AttachmentState.attaching);

  bool get isPublicInternetReady => attachment.publicInternetReady;
}

final connectionState = StateController<ConnectionState>(const ConnectionState(
    attachment: VeilidStateAttachment(
        state: AttachmentState.detached,
        publicInternetReady: false,
        localNetworkReady: false)));
final connectionStateProvider =
    StateNotifierProvider<StateController<ConnectionState>, ConnectionState>(
        (ref) => connectionState);
