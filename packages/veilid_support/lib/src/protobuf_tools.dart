import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

Future<Uint8List> protobufUpdateBytes<T extends GeneratedMessage>(
    T Function(List<int>) fromBuffer,
    Uint8List? oldBytes,
    Future<T> Function(T?) update) async {
  final oldObj = oldBytes == null ? null : fromBuffer(oldBytes);
  final newObj = await update(oldObj);
  return Uint8List.fromList(newObj.writeToBuffer());
}

Future<Uint8List> Function(Uint8List?)
    protobufUpdate<T extends GeneratedMessage>(
            T Function(List<int>) fromBuffer, Future<T> Function(T?) update) =>
        (oldBytes) => protobufUpdateBytes(fromBuffer, oldBytes, update);
