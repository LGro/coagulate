import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactsPage extends ConsumerWidget {
  const ContactsPage({super.key});
  static const path = '/contacts';

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
