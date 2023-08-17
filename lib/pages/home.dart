import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_view/split_view.dart';

import '../../entities/proto.dart' as proto;
import '../components/chat_component.dart';
import '../components/empty_chat_widget.dart';
import '../providers/account.dart';
import '../providers/chat.dart';
import '../providers/contact.dart';
import '../providers/contact_invite.dart';
import '../providers/conversation.dart';
import '../providers/window_control.dart';
import '../tools/tools.dart';
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
  Widget buildPhone(BuildContext context) {
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
    return HomePage.buildChatComponent(context, ref);
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
