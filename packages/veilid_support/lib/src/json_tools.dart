import 'dart:convert';
import 'dart:typed_data';

T jsonDecodeBytes<T>(T Function(dynamic) fromJson, Uint8List data) =>
    fromJson(jsonDecode(utf8.decode(data)));

T? jsonDecodeOptBytes<T>(T Function(dynamic) fromJson, Uint8List? data) =>
    (data == null) ? null : fromJson(jsonDecode(utf8.decode(data)));

Uint8List jsonEncodeBytes(Object? object,
        {Object? Function(Object?)? toEncodable}) =>
    Uint8List.fromList(
        utf8.encode(jsonEncode(object, toEncodable: toEncodable)));

Future<Uint8List?> jsonUpdateBytes<T>(T Function(dynamic) fromJson,
    Uint8List? oldBytes, Future<T?> Function(T?) update) async {
  final oldObj =
      oldBytes == null ? null : fromJson(jsonDecode(utf8.decode(oldBytes)));
  final newObj = await update(oldObj);
  if (newObj == null) {
    return null;
  }
  return jsonEncodeBytes(newObj);
}

Future<Uint8List?> Function(Uint8List?) jsonUpdate<T>(
        T Function(dynamic) fromJson, Future<T?> Function(T?) update) =>
    (oldBytes) => jsonUpdateBytes(fromJson, oldBytes, update);

T Function(Object?) genericFromJson<T>(
        T Function(Map<String, dynamic>) fromJsonMap) =>
    (json) => fromJsonMap(json! as Map<String, dynamic>);
