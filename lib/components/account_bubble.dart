import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:user_profile_avatar/user_profile_avatar.dart';

import '../providers/local_accounts.dart';
import '../providers/logins.dart';

class AccountBubble extends ConsumerWidget {
  const AccountBubble({super.key});

  void _onReorder(WidgetRef ref, int oldIndex, int newIndex) {
    final accounts = ref.read(localAccountsProvider.notifier);
    accounts.reorderAccount(oldIndex, newIndex);
    // xxx fix this so we can await this properly, use FutureBuilder or whatever
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    windowManager.setTitleBarStyle(TitleBarStyle.normal);
    final accounts = ref.watch(localAccountsProvider);
    final logins = ref.watch(loginsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Accounts'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Accessibility',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('Accessibility and language options coming soon')));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            accounts.when(
                error: (obj, err) => Text("error loading accounts: $err"),
                loading: () => CircularProgressIndicator(),
                data: (accountList) => ReorderableGridView.extent(
                      maxCrossAxisExtent: 128,
                      onReorder: (oldIndex, newIndex) =>
                          _onReorder(ref, oldIndex, newIndex),
                      children: accountList.map((account) {
                        return AccountBubble(account);
                      }),
                    )),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
