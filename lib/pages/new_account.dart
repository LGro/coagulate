import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewAccountPage extends ConsumerWidget {
  const NewAccountPage({super.key});
  static const path = '/new_account';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("New Account Page"),
            // ElevatedButton(
            //   onPressed: () async {
            //     ref.watch(authNotifierProvider.notifier).login(
            //           "myEmail",
            //           "myPassword",
            //         );
            //   },
            //   child: const Text("Login"),
            // ),
          ],
        ),
      ),
    );
  }
}
