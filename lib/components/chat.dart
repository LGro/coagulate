import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Chat extends ConsumerWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Home Page'),
            // ElevatedButton(
            //   onPressed: () {
            //     ref.watch(authNotifierProvider.notifier).logout();
            //   },
            //   child: const Text("Logout"),
            // ),
          ],
        ),
      ),
    );
}
