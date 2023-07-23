import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:badges/badges.dart';

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
