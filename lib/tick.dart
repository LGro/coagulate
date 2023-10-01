// XXX Eliminate this when we have ValueChanged
import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'proto/proto.dart' as proto;
import 'providers/account.dart';
import 'providers/chat.dart';
import 'providers/contact.dart';
import 'providers/contact_invite.dart';
import 'providers/conversation.dart';
import 'veilid_init.dart';

const int ticksPerContactInvitationCheck = 5;
const int ticksPerNewMessageCheck = 5;

class BackgroundTicker extends ConsumerStatefulWidget {
  const BackgroundTicker({required this.builder, super.key});

  final Widget Function(BuildContext) builder;

  @override
  BackgroundTickerState createState() => BackgroundTickerState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<Widget Function(BuildContext p1)>.has('builder', builder));
  }
}

class BackgroundTickerState extends ConsumerState<BackgroundTicker> {
  Timer? _tickTimer;
  bool _inTick = false;
  int _contactInvitationCheckTick = 0;
  int _newMessageCheckTick = 0;

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_inTick) {
        unawaited(_onTick());
      }
    });
  }

  @override
  void dispose() {
    final tickTimer = _tickTimer;
    if (tickTimer != null) {
      tickTimer.cancel();
    }

    super.dispose();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  Future<void> _onTick() async {
    // Don't tick until veilid is started
    if (!eventualVeilid.isCompleted) {
      return;
    }

    _inTick = true;
    try {
      final unord = <Future<void>>[];
      // Check extant contact invitations once every N seconds
      _contactInvitationCheckTick += 1;
      if (_contactInvitationCheckTick >= ticksPerContactInvitationCheck) {
        _contactInvitationCheckTick = 0;
        unord.add(_doContactInvitationCheck());
      }

      // Check new messages once every N seconds
      _newMessageCheckTick += 1;
      if (_newMessageCheckTick >= ticksPerNewMessageCheck) {
        _newMessageCheckTick = 0;
        unord.add(_doNewMessageCheck());
      }
      if (unord.isNotEmpty) {
        await Future.wait(unord);
      }
    } finally {
      _inTick = false;
    }
  }

  Future<void> _doContactInvitationCheck() async {
    final contactInvitationRecords =
        await ref.read(fetchContactInvitationRecordsProvider.future);
    final activeAccountInfo = await ref.read(fetchActiveAccountProvider.future);
    if (contactInvitationRecords == null || activeAccountInfo == null) {
      return;
    }

    final allChecks = <Future<void>>[];
    for (final contactInvitationRecord in contactInvitationRecords) {
      allChecks.add(() async {
        final acceptReject = await checkAcceptRejectContact(
            activeAccountInfo: activeAccountInfo,
            contactInvitationRecord: contactInvitationRecord);
        if (acceptReject != null) {
          final acceptedContact = acceptReject.acceptedContact;
          if (acceptedContact != null) {
            // Accept
            await createContact(
              activeAccountInfo: activeAccountInfo,
              profile: acceptedContact.profile,
              remoteIdentity: acceptedContact.remoteIdentity,
              remoteConversationRecordKey:
                  acceptedContact.remoteConversationRecordKey,
              localConversationRecordKey:
                  acceptedContact.localConversationRecordKey,
            );
            ref
              ..invalidate(fetchContactInvitationRecordsProvider)
              ..invalidate(fetchContactListProvider);
          } else {
            // Reject
            ref.invalidate(fetchContactInvitationRecordsProvider);
          }
        }
      }());
    }
    await Future.wait(allChecks);
  }

  Future<void> _doNewMessageCheck() async {
    final activeChat = ref.read(activeChatStateProvider);
    if (activeChat == null) {
      return;
    }
    final activeAccountInfo = await ref.read(fetchActiveAccountProvider.future);
    if (activeAccountInfo == null) {
      return;
    }

    final contactList = ref.read(fetchContactListProvider).asData?.value ??
        const IListConst([]);

    final activeChatContactIdx = contactList.indexWhere(
      (c) =>
          proto.TypedKeyProto.fromProto(c.remoteConversationRecordKey) ==
          activeChat,
    );
    if (activeChatContactIdx == -1) {
      return;
    }
    final activeChatContact = contactList[activeChatContactIdx];
    final remoteIdentityPublicKey =
        proto.TypedKeyProto.fromProto(activeChatContact.identityPublicKey);
    final remoteConversationRecordKey = proto.TypedKeyProto.fromProto(
        activeChatContact.remoteConversationRecordKey);
    final localConversationRecordKey = proto.TypedKeyProto.fromProto(
        activeChatContact.localConversationRecordKey);

    final newMessages = await getRemoteConversationMessages(
        activeAccountInfo: activeAccountInfo,
        remoteIdentityPublicKey: remoteIdentityPublicKey,
        remoteConversationRecordKey: remoteConversationRecordKey);
    if (newMessages != null) {
      final changed = await mergeLocalConversationMessages(
          activeAccountInfo: activeAccountInfo,
          localConversationRecordKey: localConversationRecordKey,
          remoteIdentityPublicKey: remoteIdentityPublicKey,
          newMessages: newMessages);
      if (changed) {
        ref.invalidate(activeConversationMessagesProvider);
      }
    }
  }
}
