// Copyright 2024 Lukas Grossberger

import 'package:flutter/material.dart';

class UpdatesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView(children: const [
        ListTile(
          title: Text('Ronja Dudeli                                    (2d)\n'
              'Name: Timo → Ronja'),
        ),
        ListTile(
          title: Text('Timo Dudeli                                    (1m)\n'
              'Home: Heimsheimer St... → Burgstraße...'),
        ),
        ListTile(
          title:
              Text('Helli Schmudela                                    (2y)\n'
                  'Work: +3011311411 → +2144242200'),
        ),
      ]);
}
