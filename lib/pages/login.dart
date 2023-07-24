import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

import '../components/account_bubble.dart';
import '../providers/local_accounts.dart';
import '../providers/logins.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});
  static const path = '/login';

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(height: 100, color: Color.fromARGB(255, 255, 0, 0)),
          Spacer(),
          // accounts.when(
          //     error: (obj, err) => Text("error loading accounts: $err"),
          //     loading: () => CircularProgressIndicator(),
          //     data: (accountList) => ReorderableGridView.extent(
          //           maxCrossAxisExtent: 128,
          //           onReorder: (oldIndex, newIndex) =>
          //               _onReorder(ref, oldIndex, newIndex),
          //           children: accountList.map<Widget>((account) {
          //             return AccountBubble(
          //                 key: ValueKey(account.identityMaster.masterRecordKey),
          //                 account: account);
          //           }).toList(),
          //         )),
          AddAccountBubble(key: ValueKey("+")),
          Spacer(),
          Container(height: 100, color: Color.fromARGB(255, 0, 255, 0)),
        ],
      ),
    );
  }
}
