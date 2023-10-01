import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';

import '../proto/proto.dart' as proto;
import '../components/chat_component.dart';
import '../components/empty_chat_widget.dart';
import '../components/profile_widget.dart';
import '../entities/local_account.dart';
import '../providers/account.dart';
import '../providers/chat.dart';
import '../providers/contact.dart';
import '../providers/local_accounts.dart';
import '../providers/logins.dart';
import '../providers/window_control.dart';
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'main_pager/main_pager.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();

  static Widget buildChatComponent(BuildContext context, WidgetRef ref) {
    final contactList = ref.watch(fetchContactListProvider).asData?.value ??
        const IListConst([]);

    final activeChat = ref.watch(activeChatStateProvider).asData?.value;
    if (activeChat == null) {
      return const EmptyChatWidget();
    }

    final activeAccountInfo =
        ref.watch(fetchActiveAccountProvider).asData?.value;
    if (activeAccountInfo == null) {
      return const EmptyChatWidget();
    }

    final activeChatContactIdx = contactList.indexWhere(
      (c) =>
          proto.TypedKeyProto.fromProto(c.remoteConversationRecordKey) ==
          activeChat,
    );
    if (activeChatContactIdx == -1) {
      activeChatState.add(null);
      return const EmptyChatWidget();
    }
    final activeChatContact = contactList[activeChatContactIdx];

    return ChatComponent(
        activeAccountInfo: activeAccountInfo,
        activeChat: activeChat,
        activeChatContact: activeChatContact);
  }
}

class HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
      await ref.read(windowControlProvider.notifier).changeWindowSetup(
          TitleBarStyle.normal, OrientationCapability.normal);
    });
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  // ignore: prefer_expression_function_bodies
  Widget buildAccountList() {
    return const Column(children: [
      Center(child: Text('Small Profile')),
      Center(child: Text('Contact invitations')),
      Center(child: Text('Contacts'))
    ]);
  }

  Widget buildUnlockAccount(
    BuildContext context,
    IList<LocalAccount> localAccounts,
    // ignore: prefer_expression_function_bodies
  ) {
    return const Center(child: Text('unlock account'));
  }

  /// We have an active, unlocked, user login
  Widget buildReadyAccount(
      BuildContext context,
      IList<LocalAccount> localAccounts,
      TypedKey activeUserLogin,
      proto.Account account) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    return Column(children: <Widget>[
      Row(children: [
        IconButton(
            icon: const Icon(Icons.settings),
            color: scale.secondaryScale.text,
            constraints: const BoxConstraints.expand(height: 64, width: 64),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(scale.secondaryScale.border),
                shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))))),
            tooltip: translate('app_bar.settings_tooltip'),
            onPressed: () async {
              context.go('/home/settings');
            }).paddingLTRB(0, 0, 8, 0),
        ProfileWidget(
          name: account.profile.name,
          pronouns: account.profile.pronouns,
        ).expanded(),
      ]).paddingAll(8),
      MainPager(
              localAccounts: localAccounts,
              activeUserLogin: activeUserLogin,
              account: account)
          .expanded()
    ]);
  }

  Widget buildUserPanel() {
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
      return buildAccountList();
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
          await showErrorModal(context, translate('home.missing_account_title'),
              translate('home.missing_account_text'));
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
          await showErrorModal(context, translate('home.invalid_account_title'),
              translate('home.invalid_account_text'));
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
        return buildReadyAccount(
          context,
          localAccounts,
          activeUserLogin,
          account.account!,
        );
    }
  }

  // ignore: prefer_expression_function_bodies
  Widget buildPhone(BuildContext context) {
    return Material(color: Colors.transparent, child: buildUserPanel());
  }

  // ignore: prefer_expression_function_bodies
  Widget buildTabletLeftPane(BuildContext context) {
    //
    return Material(color: Colors.transparent, child: buildUserPanel());
  }

  // ignore: prefer_expression_function_bodies
  Widget buildTabletRightPane(BuildContext context) {
    //
    return HomePage.buildChatComponent(context, ref);
  }

  // ignore: prefer_expression_function_bodies
  Widget buildTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    final children = [
      ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 300),
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: w / 2),
              child: buildTabletLeftPane(context))),
      SizedBox(
          width: 2,
          height: double.infinity,
          child: ColoredBox(color: scale.primaryScale.hoverBorder)),
      Expanded(child: buildTabletRightPane(context)),
    ];

    return Row(
      children: children,
    );

    // final theme = MultiSplitViewTheme(
    //     data: isDesktop
    //         ? MultiSplitViewThemeData(
    //             dividerThickness: 1,
    //             dividerPainter: DividerPainters.grooved2(thickness: 1))
    //         : MultiSplitViewThemeData(
    //             dividerThickness: 3,
    //             dividerPainter: DividerPainters.grooved2(thickness: 1)),
    //     child: multiSplitView);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(windowControlProvider);

    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    return SafeArea(
        child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: scale.primaryScale.activeElementBackground),
              child: responsiveVisibility(
                context: context,
                phone: false,
              )
                  ? buildTablet(context)
                  : buildPhone(context),
            )));
  }
}
