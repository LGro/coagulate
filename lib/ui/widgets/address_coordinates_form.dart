// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'dart:io';

import 'package:flutter/material.dart';

typedef UpdateLngLatCallback = void Function(num, num);

class AddressCoordinatesForm extends StatefulWidget {
  const AddressCoordinatesForm(
      {required this.i,
      super.key,
      this.longitude,
      this.latitude,
      this.callback});

  final int i;
  final num? longitude;
  final num? latitude;
  final UpdateLngLatCallback? callback;

  @override
  _AddressCoordinatesFormState createState() => _AddressCoordinatesFormState();
}

class _AddressCoordinatesFormState extends State<AddressCoordinatesForm> {
  late TextEditingController _lngController;
  late TextEditingController _latController;

  @override
  void initState() {
    super.initState();
    _lngController = TextEditingController(text: '${widget.longitude}');
    _latController = TextEditingController(text: '${widget.latitude}');
  }

  @override
  void didUpdateWidget(covariant AddressCoordinatesForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.longitude != widget.longitude) {
      _lngController.text = '${widget.longitude}';
    }
    if (oldWidget.latitude != widget.latitude) {
      _latController.text = '${widget.latitude}';
    }
  }

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              key: Key('addressCoordinatesForm_${widget.i}Longitude'),
              controller: _lngController,
              // On iOS the number input has no done button and thus can't be dismissed
              keyboardType: Platform.isIOS
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                  isDense: true),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              key: Key('addressCoordinatesForm_${widget.i}Latitude'),
              controller: _latController,
              // On iOS the number input has no done button and thus can't be dismissed
              keyboardType: Platform.isIOS
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                  isDense: true),
            ),
          ),
          TextButton(
              onPressed: (num.tryParse(_lngController.text) != null &&
                      num.tryParse(_latController.text) != null &&
                      widget.callback != null)
                  ? () => widget.callback!(num.parse(_lngController.text),
                      num.parse(_latController.text))
                  : null,
              child: const Text('Save')),
        ],
      );

  @override
  void dispose() {
    _lngController.dispose();
    _latController.dispose();
    super.dispose();
  }
}
