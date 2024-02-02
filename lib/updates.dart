// Copyright 2024 Lukas Grossberger

import 'package:flutter/material.dart';

class UpdatesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView(
        children: List.generate(
          10,
          (index) => ListTile(
            title: Text('Update $index'),
          ),
        ),
      );
}
