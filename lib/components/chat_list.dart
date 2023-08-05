import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatList extends ConsumerWidget {
  const ChatList({super.key});
  //final LocalAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final logins = ref.watch(loginsProvider);

    return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [const Expanded(child: Text('Chat List'))]));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    //properties.add(DiagnosticsProperty<LocalAccount>('account', account));
  }
}