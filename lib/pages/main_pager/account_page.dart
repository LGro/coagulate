import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../components/contact_invitation_list_widget.dart';
import '../../components/contact_list_widget.dart';
import '../../components/profile_widget.dart';
import '../../entities/local_account.dart';
import '../../entities/proto.dart' as proto;
import '../../providers/account.dart';
import '../../providers/contact.dart';
import '../../providers/local_accounts.dart';
import '../../providers/logins.dart';
import '../../tools/tools.dart';
import '../../veilid_support/veilid_support.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends ConsumerState<AccountPage> {
  final _unfocusNode = FocusNode();
  TypedKey? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _selectedAccount = null;
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  // ignore: prefer_expression_function_bodies
  Widget buildAccountList(BuildContext context) {
    return Column(children: [
      Center(child: Text("Small Profile")),
      Center(child: Text("Contact invitations")),
      Center(child: Text("Contacts"))
    ]);
  }

  Widget buildUnlockAccount(
    BuildContext context,
    IList<LocalAccount> localAccounts,
    // ignore: prefer_expression_function_bodies
  ) {
    return Center(child: Text("unlock account"));
  }

  /// We have an active, unlocked, user login
  Widget buildUserAccount(
    BuildContext context,
    IList<LocalAccount> localAccounts,
    TypedKey activeUserLogin,
    proto.Account account,
    // ignore: prefer_expression_function_bodies
  ) {
    final contactInvitationRecordList =
        ref.watch(fetchContactInvitationRecordsProvider).asData?.value ??
            const IListConst([]);
    final contactList = ref.watch(fetchContactListProvider).asData?.value ??
        const IListConst([]);

    return Column(children: <Widget>[
      ProfileWidget(name: account.profile.name, title: account.profile.title),
      if (contactInvitationRecordList.isNotEmpty)
        ExpansionTile(
          title: Text(translate('account_page.contact_invitations')),
          initiallyExpanded: true,
          children: [
            ContactInvitationListWidget(
                contactInvitationRecordList: contactInvitationRecordList)
          ],
        ),
      ContactListWidget(contactList: contactList).expanded(),
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
      // If no logged in user is active, show the list of account
      return buildAccountList(context);
    }
    final accountV = ref
        .watch(fetchAccountProvider(accountMasterRecordKey: activeUserLogin));
    if (!accountV.hasValue) {
      return waitingPage(context);
    }
    final account = accountV.requireValue;
    switch (account.status) {
      case AccountInfoStatus.noAccount:
        Future.delayed(0.ms, () async {
          await showErrorModal(
              context,
              translate('account_page.missing_account_title'),
              translate('account_page.missing_account_text'));
          // Delete account
          await ref
              .read(localAccountsProvider.notifier)
              .deleteLocalAccount(activeUserLogin);
          // Switch to no active user login
          await ref.read(loginsProvider.notifier).switchToAccount(null);
        });
        return waitingPage(context);
      case AccountInfoStatus.accountInvalid:
        Future.delayed(0.ms, () async {
          await showErrorModal(
              context,
              translate('account_page.invalid_account_title'),
              translate('account_page.invalid_account_text'));
          // Delete account
          await ref
              .read(localAccountsProvider.notifier)
              .deleteLocalAccount(activeUserLogin);
          // Switch to no active user login
          await ref.read(loginsProvider.notifier).switchToAccount(null);
        });
        return waitingPage(context);
      case AccountInfoStatus.accountLocked:
        // Show unlock widget
        return buildUnlockAccount(context, localAccounts);
      case AccountInfoStatus.accountReady:
        return buildUserAccount(
          context,
          localAccounts,
          activeUserLogin,
          account.account!,
        );
    }
  }
}
