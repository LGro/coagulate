import 'package:flutter/material.dart';

typedef UpdateLngLatCallback = void Function(num, num);

class AddressCoordinatesForm extends StatefulWidget {
  final num? lng;
  final num? lat;
  final UpdateLngLatCallback? callback;

  AddressCoordinatesForm({super.key, this.lng, this.lat, this.callback});

  @override
  _AddressCoordinatesFormState createState() => _AddressCoordinatesFormState();
}

class _AddressCoordinatesFormState extends State<AddressCoordinatesForm> {
  late TextEditingController _lngController;
  late TextEditingController _latController;

  @override
  void initState() {
    super.initState();
    _lngController = TextEditingController(
        text: (widget.lng != null) ? widget.lng.toString() : '');
    _latController = TextEditingController(
        text: (widget.lat != null) ? widget.lat.toString() : '');
  }

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: _lngController,
              decoration: const InputDecoration(
                  labelText: 'Longitude', border: OutlineInputBorder()),
              onChanged: (value) => setState(() {
                _lngController
                  ..text = value
                  ..selection = TextSelection.fromPosition(
                      TextPosition(offset: value.length));
              }),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: _latController,
              decoration: const InputDecoration(
                  labelText: 'Latitude', border: OutlineInputBorder()),
              onChanged: (value) => setState(() {
                _latController
                  ..text = value
                  ..selection = TextSelection.fromPosition(
                      TextPosition(offset: value.length));
              }),
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
