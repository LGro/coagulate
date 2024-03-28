import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

part 'processor_connection_state.freezed.dart';

@freezed
class ProcessorConnectionState with _$ProcessorConnectionState {
  const factory ProcessorConnectionState({
    required VeilidStateAttachment attachment,
    required VeilidStateNetwork network,
  }) = _ProcessorConnectionState;
  const ProcessorConnectionState._();

  bool get isAttached => !(attachment.state == AttachmentState.detached ||
      attachment.state == AttachmentState.detaching ||
      attachment.state == AttachmentState.attaching);

  bool get isPublicInternetReady => attachment.publicInternetReady;
}
