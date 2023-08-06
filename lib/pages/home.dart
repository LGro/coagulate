import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_view/split_view.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';

import '../components/chat_component.dart';
import '../providers/account.dart';
import '../providers/contact.dart';
import '../providers/contact_invite.dart';
import '../providers/window_control.dart';
import '../tools/tools.dart';
import 'main_pager/main_pager.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static const path = '/home';

  @override
  HomePageState createState() => HomePageState();
}

// XXX Eliminate this when we have ValueChanged
const int ticksPerContactInvitationCheck = 5;

class HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  final _unfocusNode = FocusNode();

  Timer? _homeTickTimer;
  bool _inHomeTick = false;
  int _contactInvitationCheckTick = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
      await ref.read(windowControlProvider.notifier).changeWindowSetup(
          TitleBarStyle.normal, OrientationCapability.normal);

      _homeTickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_inHomeTick) {
          unawaited(_onHomeTick());
        }
      });
    });
  }

  @override
  void dispose() {
    final homeTickTimer = _homeTickTimer;
    if (homeTickTimer != null) {
      homeTickTimer.cancel();
    }
    _unfocusNode.dispose();
    super.dispose();
  }

  Future<void> _onHomeTick() async {
    _inHomeTick = true;
    try {
      // Check extant contact invitations once every 5 seconds
      _contactInvitationCheckTick += 1;
      if (_contactInvitationCheckTick >= ticksPerContactInvitationCheck) {
        _contactInvitationCheckTick = 0;
        await _doContactInvitationCheck();
      }
    } finally {
      _inHomeTick = false;
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
              remoteConversationKey: acceptedContact.remoteConversationKey,
              localConversation: acceptedContact.localConversation,
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

  // ignore: prefer_expression_function_bodies
  Widget buildPhone(BuildContext context) {
    //
    return Material(
        color: Colors.transparent, elevation: 4, child: MainPager());
  }

  // ignore: prefer_expression_function_bodies
  Widget buildTabletLeftPane(BuildContext context) {
    //
    return Material(
        color: Colors.transparent, elevation: 4, child: MainPager());
  }

  // ignore: prefer_expression_function_bodies
  Widget buildTabletRightPane(BuildContext context) {
    //
    return ChatComponent();
  }

  // ignore: prefer_expression_function_bodies
  Widget buildTablet(BuildContext context) {
    final theme = Theme.of(context);
    final w = MediaQuery.of(context).size.width;
    final children = [
      ConstrainedBox(
          constraints: BoxConstraints(minWidth: 300, maxWidth: 300),
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: w / 2),
              child: buildTabletLeftPane(context))),
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

    return SafeArea(
        child: GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: responsiveVisibility(
        context: context,
        phone: false,
      )
          ? buildTablet(context)
          : buildPhone(context),
    ));
  }
}
