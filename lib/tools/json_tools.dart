import 'package:veilid/veilid.dart';
import 'dart:typed_data';
import 'dart:convert';

T jsonDecodeBytes<T>(
    T Function(Map<String, dynamic>) fromJson, Uint8List data) {
  return fromJson(jsonDecode(utf8.decode(data)));
}

Uint8List jsonEncodeBytes(Object? object,
    {Object? Function(Object?)? toEncodable}) {
  return Uint8List.fromList(
      utf8.encode(jsonEncode(object, toEncodable: toEncodable)));
}

Future<Uint8List> jsonUpdateBytes<T>(T Function(Map<String, dynamic>) fromJson,
    Uint8List oldBytes, Future<T> Function(T) update) async {
  T oldObj = fromJson(jsonDecode(utf8.decode(oldBytes)));
  T newObj = await update(oldObj);
  return jsonEncodeBytes(newObj);
}

Future<Uint8List> Function(Uint8List) jsonUpdate<T>(
    T Function(Map<String, dynamic>) fromJson, Future<T> Function(T) update) {
  return (Uint8List oldBytes) {
    return jsonUpdateBytes(fromJson, oldBytes, update);
  };
}

T Function(Object?) genericFromJson<T>(
    T Function(Map<String, dynamic>) fromJsonMap) {
  return (Object? json) {
    return fromJsonMap(json as Map<String, dynamic>);
  };
}
