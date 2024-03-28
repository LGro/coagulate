import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:veilid/veilid.dart';

Future<T> tableScope<T>(
    String name, Future<T> Function(VeilidTableDB tdb) callback,
    {int columnCount = 1}) async {
  final tableDB = await Veilid.instance.openTableDB(name, columnCount);
  try {
    return await callback(tableDB);
  } finally {
    tableDB.close();
  }
}

Future<T> transactionScope<T>(
  VeilidTableDB tdb,
  Future<T> Function(VeilidTableDBTransaction tdbt) callback,
) async {
  final tdbt = tdb.transact();
  try {
    final ret = await callback(tdbt);
    if (!tdbt.isDone()) {
      await tdbt.commit();
    }
    return ret;
  } finally {
    if (!tdbt.isDone()) {
      await tdbt.rollback();
    }
  }
}

abstract mixin class TableDBBacked<T> {
  String tableName();
  String tableKeyName();
  T valueFromJson(Object? obj);
  Object? valueToJson(T val);

  /// Load things from storage
  Future<T> load() async {
    final obj = await tableScope(tableName(), (tdb) async {
      final objJson = await tdb.loadStringJson(0, tableKeyName());
      return valueFromJson(objJson);
    });
    return obj;
  }

  /// Store things to storage
  Future<T> store(T obj) async {
    await tableScope(tableName(), (tdb) async {
      await tdb.storeStringJson(0, tableKeyName(), valueToJson(obj));
    });
    return obj;
  }
}

class TableDBValue<T> extends TableDBBacked<T> {
  TableDBValue({
    required String tableName,
    required String tableKeyName,
    required T Function(Object? obj) valueFromJson,
    required Object? Function(T obj) valueToJson,
  })  : _tableName = tableName,
        _valueFromJson = valueFromJson,
        _valueToJson = valueToJson,
        _tableKeyName = tableKeyName,
        _streamController = StreamController<T>.broadcast();

  AsyncData<T>? get value => _value;
  T get requireValue => _value!.value;
  Stream<T> get stream => _streamController.stream;

  Future<T> get() async {
    final val = _value;
    if (val != null) {
      return val.value;
    }
    final loadedValue = await load();
    _value = AsyncData(loadedValue);
    return loadedValue;
  }

  Future<void> set(T newVal) async {
    _value = AsyncData(await store(newVal));
    _streamController.add(newVal);
  }

  AsyncData<T>? _value;
  final String _tableName;
  final String _tableKeyName;
  final T Function(Object? obj) _valueFromJson;
  final Object? Function(T obj) _valueToJson;
  final StreamController<T> _streamController;

  //////////////////////////////////////////////////////////////
  /// AsyncTableDBBacked
  @override
  String tableName() => _tableName;
  @override
  String tableKeyName() => _tableKeyName;
  @override
  T valueFromJson(Object? obj) => _valueFromJson(obj);
  @override
  Object? valueToJson(T val) => _valueToJson(val);
}
