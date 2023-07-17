export 'external_stream_state.dart';
import 'package:veilid/veilid.dart';
import 'dart:convert';

extension FromValueDataJsonExt on ValueData {
  T readJsonData<T>(T Function(Map<String, dynamic>) fromJson) {
    return fromJson(jsonDecode(utf8.decode(data)));
  }
}
