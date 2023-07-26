import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatIndex extends ConsumerWidget {
  const ChatIndex({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Contacts Page'),
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
