import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/chat_single_contact_list_widget.dart';
import '../../components/empty_chat_list_widget.dart';
import '../../entities/local_account.dart';
import '../../proto/proto.dart' as proto;
import '../../providers/account.dart';
import '../../providers/chat.dart';
import '../../providers/contact.dart';
import '../../providers/local_accounts.dart';
import '../../providers/logins.dart';
import '../../tools/tools.dart';
import '../../veilid_support/veilid_support.dart';

class ChatsPage extends ConsumerStatefulWidget {
  const ChatsPage({super.key});

  @override
  ChatsPageState createState() => ChatsPageState();
}

class ChatsPageState extends ConsumerState<ChatsPage> {
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  /// We have an active, unlocked, user login
  Widget buildChatList(
    BuildContext context,
    IList<LocalAccount> localAccounts,
    TypedKey activeUserLogin,
    proto.Account account,
    // ignore: prefer_expression_function_bodies
  ) {
    final contactList = ref.watch(fetchContactListProvider).asData?.value ??
        const IListConst([]);
    final chatList =
        ref.watch(fetchChatListProvider).asData?.value ?? const IListConst([]);

    return Column(children: <Widget>[
      if (chatList.isNotEmpty)
        ChatSingleContactListWidget(
                contactList: contactList, chatList: chatList)
            .expanded(),
      if (chatList.isEmpty) const EmptyChatListWidget().expanded(),
    ]);
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final localAccountsV = ref.watch(localAccountsProvider);
    final loginsV = ref.watch(loginsProvider);

    if (!localAccountsV.hasValue || !loginsV.hasValue) {
      return waitingPage(context);
    }
    final localAccounts = localAccountsV.requireValue;
    final logins = loginsV.requireValue;

    final activeUserLogin = logins.activeUserLogin;
    if (activeUserLogin == null) {
      // If no logged in user is active show a placeholder
      return waitingPage(context);
    }
    final accountV = ref
        .watch(fetchAccountProvider(accountMasterRecordKey: activeUserLogin));
    if (!accountV.hasValue) {
      return waitingPage(context);
    }
    final account = accountV.requireValue;
    switch (account.status) {
      case AccountInfoStatus.noAccount:
        return waitingPage(context);
      case AccountInfoStatus.accountInvalid:
        return waitingPage(context);
      case AccountInfoStatus.accountLocked:
        return waitingPage(context);
      case AccountInfoStatus.accountReady:
        return buildChatList(
          context,
          localAccounts,
          activeUserLogin,
          account.account!,
        );
    }
  }
}
