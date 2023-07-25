import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:badges/badges.dart';
import 'package:awesome_extensions/awesome_extensions.dart';

import '../entities/local_account.dart';
import '../providers/logins.dart';

class AccountBubble extends ConsumerWidget {
  final LocalAccount account;

  const AccountBubble({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    windowManager.setTitleBarStyle(TitleBarStyle.normal);
    final logins = ref.watch(loginsProvider);

    return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              flex: 4,
              child: CircularProfileAvatar("",
                  child: Container(color: Theme.of(context).disabledColor))),
          Expanded(flex: 1, child: Text("Placeholder"))
        ]));
  }
}

class AddAccountBubble extends ConsumerWidget {
  const AddAccountBubble({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    windowManager.setTitleBarStyle(TitleBarStyle.normal);
    final logins = ref.watch(loginsProvider);

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircularProfileAvatar("",
          borderWidth: 4,
          borderColor: Theme.of(context).unselectedWidgetColor,
          child: Container(
              color: Colors.blue, child: const Icon(Icons.add, size: 50))),
      const Text("Add Account").paddingLTRB(0, 4, 0, 0)
    ]);
  }
}