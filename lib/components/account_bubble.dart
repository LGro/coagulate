import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../entities/local_account.dart';
import '../providers/logins.dart';

class AccountBubble extends ConsumerWidget {
  const AccountBubble({required this.account, super.key});
  final LocalAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    windowManager.setTitleBarStyle(TitleBarStyle.normal);
    final logins = ref.watch(loginsProvider);

    return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              flex: 4,
              child: CircularProfileAvatar('',
                  child: Container(color: Theme.of(context).disabledColor))),
          const Expanded(child: Text('Placeholder'))
        ]));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LocalAccount>('account', account));
  }
}

class AddAccountBubble extends ConsumerWidget {
  const AddAccountBubble({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    windowManager.setTitleBarStyle(TitleBarStyle.normal);
    final logins = ref.watch(loginsProvider);

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircularProfileAvatar('',
          borderWidth: 4,
          borderColor: Theme.of(context).unselectedWidgetColor,
          child: Container(
              color: Colors.blue, child: const Icon(Icons.add, size: 50))),
      const Text('Add Account').paddingLTRB(0, 4, 0, 0)
    ]);
  }
}
