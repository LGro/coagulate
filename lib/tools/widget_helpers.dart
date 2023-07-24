import 'package:flutter/material.dart';

extension BorderExt on Widget {
  Container debugBorder() {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.redAccent)),
        child: this);
  }
}
