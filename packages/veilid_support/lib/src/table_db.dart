import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:meta/meta.dart';
import 'package:veilid/veilid.dart';

import '../veilid_support.dart';
import 'veilid_log.dart';

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

abstract mixin class TableDBBackedJson<T> {
  @protected
  String tableName();
  @protected
  String tableKeyName();
  @protected
  T? valueFromJson(Object? obj);
  @protected
  Object? valueToJson(T? val);

  /// Load things from storage
  @protected
  Future<T?> load() async {
    try {
      final obj = await tableScope(tableName(), (tdb) async {
        final objJson = await tdb.loadStringJson(0, tableKeyName());
        return valueFromJson(objJson);
      });
      return obj;
    } on Exception catch (e, st) {
      veilidLoggy.debug(
          'Unable to load data from table store: '
          '${tableName()}:${tableKeyName()}',
          e,
          st);
      return null;
    }
  }

  /// Store things to storage
  @protected
  Future<T> store(T obj) async {
    await tableScope(tableName(), (tdb) async {
      await tdb.storeStringJson(0, tableKeyName(), valueToJson(obj));
    });
    return obj;
  }

  /// Delete things from storage
  @protected
  Future<T?> delete() async {
    final obj = await tableScope(tableName(), (tdb) async {
      final objJson = await tdb.deleteStringJson(0, tableKeyName());
      return valueFromJson(objJson);
    });
    return obj;
  }
}

abstract mixin class TableDBBackedFromBuffer<T> {
  @protected
  String tableName();
  @protected
  String tableKeyName();
  @protected
  T valueFromBuffer(Uint8List bytes);
  @protected
  Uint8List valueToBuffer(T val);

  /// Load things from storage
  @protected
  Future<T?> load() async {
    final obj = await tableScope(tableName(), (tdb) async {
      final objBytes = await tdb.load(0, utf8.encode(tableKeyName()));
      if (objBytes == null) {
        return null;
      }
      return valueFromBuffer(objBytes);
    });
    return obj;
  }

  /// Store things to storage
  @protected
  Future<T> store(T obj) async {
    await tableScope(tableName(), (tdb) async {
      await tdb.store(0, utf8.encode(tableKeyName()), valueToBuffer(obj));
    });
    return obj;
  }

  /// Delete things from storage
  @protected
  Future<T?> delete() async {
    final obj = await tableScope(tableName(), (tdb) async {
      final objBytes = await tdb.delete(0, utf8.encode(tableKeyName()));
      if (objBytes == null) {
        return null;
      }
      return valueFromBuffer(objBytes);
    });
    return obj;
  }
}

class TableDBValue<T> extends TableDBBackedJson<T> {
  TableDBValue({
    required String tableName,
    required String tableKeyName,
    required T? Function(Object? obj) valueFromJson,
    required Object? Function(T? obj) valueToJson,
    required T Function() makeInitialValue,
  })  : _tableName = tableName,
        _valueFromJson = valueFromJson,
        _valueToJson = valueToJson,
        _tableKeyName = tableKeyName,
        _makeInitialValue = makeInitialValue,
        _streamController = StreamController<T>.broadcast() {
    _initWait.add((_) async {
      await get();
    });
  }

  Future<void> init() async {
    await _initWait();
  }

  Future<void> close() async {
    await _initWait();
  }

  T get value => _value!.value;
  Stream<T> get stream => _streamController.stream;

  Future<T> get() async {
    final val = _value;
    if (val != null) {
      return val.value;
    }
    final loadedValue = await load() ?? await store(_makeInitialValue());
    _value = AsyncData(loadedValue);
    return loadedValue;
  }

  Future<void> set(T newVal) async {
    _value = AsyncData(await store(newVal));
    _streamController.add(newVal);
  }

  AsyncData<T>? _value;
  final T Function() _makeInitialValue;
  final String _tableName;
  final String _tableKeyName;
  final T? Function(Object? obj) _valueFromJson;
  final Object? Function(T? obj) _valueToJson;
  final StreamController<T> _streamController;
  final WaitSet<void, void> _initWait = WaitSet();

  //////////////////////////////////////////////////////////////
  /// AsyncTableDBBacked
  @override
  String tableName() => _tableName;
  @override
  String tableKeyName() => _tableKeyName;
  @override
  T? valueFromJson(Object? obj) => _valueFromJson(obj);
  @override
  Object? valueToJson(T? val) => _valueToJson(val);
}
