import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/window_control.dart';
import '../tools/tools.dart';
import 'home.dart';

class ChatOnlyPage extends ConsumerStatefulWidget {
  const ChatOnlyPage({super.key});
  static const path = '/chat';

  @override
  ChatOnlyPageState createState() => ChatOnlyPageState();
}

class ChatOnlyPageState extends ConsumerState<ChatOnlyPage>
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

  @override
  Widget build(BuildContext context) {
    ref.watch(windowControlProvider);

    return SafeArea(
        child: GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: HomePage.buildChatComponent(context, ref),
    ));
  }
}
