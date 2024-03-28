import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract mixin class SharedPreferencesBacked<T> {
  SharedPreferences get _sharedPreferences;
  String keyName();
  T valueFromJson(Object? obj);
  Object? valueToJson(T val);

  /// Load things from storage
  Future<T> load() async {
    final valueJsonStr = _sharedPreferences.getString(keyName());
    final Object? valueJsonObj =
        valueJsonStr != null ? jsonDecode(valueJsonStr) : null;
    return valueFromJson(valueJsonObj);
  }

  /// Store things to storage
  Future<T> store(T obj) async {
    final valueJsonObj = valueToJson(obj);
    if (valueJsonObj == null) {
      await _sharedPreferences.remove(keyName());
    } else {
      await _sharedPreferences.setString(keyName(), jsonEncode(valueJsonObj));
    }
    return obj;
  }
}

class SharedPreferencesValue<T> extends SharedPreferencesBacked<T> {
  SharedPreferencesValue({
    required SharedPreferences sharedPreferences,
    required String keyName,
    required T Function(Object? obj) valueFromJson,
    required Object? Function(T obj) valueToJson,
  })  : _sharedPreferencesInstance = sharedPreferences,
        _valueFromJson = valueFromJson,
        _valueToJson = valueToJson,
        _keyName = keyName,
        _streamController = StreamController<T>.broadcast();

  @override
  SharedPreferences get _sharedPreferences => _sharedPreferencesInstance;

  T? get value => _value;
  T get requireValue => _value!;
  Stream<T> get stream => _streamController.stream;

  Future<T> get() async {
    final val = _value;
    if (val != null) {
      return val;
    }
    final loadedValue = await load();
    return _value = loadedValue;
  }

  Future<void> set(T newVal) async {
    _value = await store(newVal);
    _streamController.add(newVal);
  }

  T? _value;
  final SharedPreferences _sharedPreferencesInstance;
  final String _keyName;
  final T Function(Object? obj) _valueFromJson;
  final Object? Function(T obj) _valueToJson;
  final StreamController<T> _streamController;

  //////////////////////////////////////////////////////////////
  /// SharedPreferencesBacked
  @override
  String keyName() => _keyName;
  @override
  T valueFromJson(Object? obj) => _valueFromJson(obj);
  @override
  Object? valueToJson(T val) => _valueToJson(val);
}
