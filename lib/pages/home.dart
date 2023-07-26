import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  static const path = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
      appBar: AppBar(title: const Text('VeilidChat')),
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
