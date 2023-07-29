import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:veilid/veilid.dart';

import '../../components/profile.dart';
import '../../entities/local_account.dart';
import '../../entities/proto.dart' as proto;
import '../../providers/account.dart';
import '../../providers/local_accounts.dart';
import '../../providers/logins.dart';
import '../../tools/tools.dart';

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

  @override
  // ignore: prefer_expression_function_bodies
  Widget buildAccountList(BuildContext context) {
    return Center(child: Text("account list"));
  }

  @override
  Widget buildUnlockAccount(
    BuildContext context,
    IList<LocalAccount> localAccounts,
    // ignore: prefer_expression_function_bodies
  ) {
    return Center(child: Text("unlock account"));
  }

  @override
  Widget buildUserAccount(
    BuildContext context,
    IList<LocalAccount> localAccounts,
    TypedKey activeUserLogin,
    proto.Account account,
    // ignore: prefer_expression_function_bodies
  ) {
    return ProfileWidget(
        name: account.profile.name, title: account.profile.title);
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
              .deleteAccount(activeUserLogin);
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
              .deleteAccount(activeUserLogin);
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
