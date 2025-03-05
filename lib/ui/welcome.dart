import 'dart:async';

import 'package:flutter/material.dart';
import 'utils.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen(this.setNameCallback);
  final Future<void> Function(String name) setNameCallback;

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _onSubmit() async {
    if (_nameController.text.isNotEmpty) {
      await widget.setNameCallback(_nameController.text.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.welcomeErrorNameMissing)),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.loc.welcomeHeadline,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(context.loc.welcomeText,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: context.loc.name.capitalize(),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: _onSubmit,
                            child: Text(context.loc.welcomeCallToActionButton),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
