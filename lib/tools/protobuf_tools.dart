import 'package:protobuf/protobuf.dart';
import 'dart:typed_data';

Future<Uint8List> protobufUpdateBytes<T extends GeneratedMessage>(
    T Function(List<int>) fromBuffer,
    Uint8List oldBytes,
    Future<T> Function(T) update) async {
  T oldObj = fromBuffer(oldBytes);
  T newObj = await update(oldObj);
  return Uint8List.fromList(newObj.writeToBuffer());
}

Future<Uint8List> Function(Uint8List)
    protobufUpdate<T extends GeneratedMessage>(
        T Function(List<int>) fromBuffer, Future<T> Function(T) update) {
  return (Uint8List oldBytes) {
    return protobufUpdateBytes(fromBuffer, oldBytes, update);
  };
}
