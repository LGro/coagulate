import 'package:flutter/material.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});
  static const path = '/';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Index Page")),
    );
  }
}
