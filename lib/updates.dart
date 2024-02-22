// Copyright 2024 Lukas Grossberger
import 'package:flutter/material.dart';

Widget updateTile(String name, String timing, String change) => ListTile(
        title: Column(children: [
      Row(
        children: [
          Expanded(child: Text(name)),
          Text(timing, style: const TextStyle(color: Colors.black54))
        ],
      ),
      Row(
        children: [Text(change)],
      )
    ]));

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
      ),
      body: ListView(children: [
        updateTile('Ronja Dudeli', '(2d)', 'Name: Timo => Ronja'),
        updateTile(
            'Timo Dudeli', '(1m)', 'Home: Heimsheimer St... => Burgstraße...'),
        updateTile(
            'Helli Schmudela', '(2y)', 'Work: +3011311411 => +2144242200'),
      ]));
}
