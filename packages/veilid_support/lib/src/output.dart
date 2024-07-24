import 'package:fast_immutable_collections/fast_immutable_collections.dart';

export 'package:fast_immutable_collections/fast_immutable_collections.dart'
    show Output;

extension OutputNullExt<T> on Output<T>? {
  void mapSave<S>(Output<S>? other, T Function(S output) closure) {
    if (this == null) {
      return;
    }
    if (other == null) {
      return;
    }
    final v = other.value;
    if (v == null) {
      return;
    }
    return this!.save(closure(v));
  }
}

extension OutputExt<T> on Output<T> {
  void mapSave<S>(Output<S>? other, T Function(S output) closure) {
    if (other == null) {
      return;
    }
    final v = other.value;
    if (v == null) {
      return;
    }
    return save(closure(v));
  }
}
