import 'dart:typed_data';

import '../../../veilid_support.dart';

/// Cubit that watches the default subkey value of a dhtrecord
class DefaultDHTRecordCubit<T> extends DHTRecordCubit<T> {
  DefaultDHTRecordCubit({
    required super.open,
    required T Function(List<int> data) decodeState,
  }) : super(
            initialStateFunction: _makeInitialStateFunction(decodeState),
            stateFunction: _makeStateFunction(decodeState),
            watchFunction: _makeWatchFunction());

  static InitialStateFunction<T> _makeInitialStateFunction<T>(
          T Function(List<int> data) decodeState) =>
      (record) async {
        final initialData = await record.get();
        if (initialData == null) {
          return null;
        }
        return decodeState(initialData);
      };

  static StateFunction<T> _makeStateFunction<T>(
          T Function(List<int> data) decodeState) =>
      (record, subkeys, updatedata) async {
        final defaultSubkey = record.subkeyOrDefault(-1);
        if (subkeys.containsSubkey(defaultSubkey)) {
          final Uint8List data;
          final firstSubkey = subkeys.firstOrNull!.low;
          if (firstSubkey != defaultSubkey || updatedata == null) {
            final maybeData =
                await record.get(refreshMode: DHTRecordRefreshMode.network);
            if (maybeData == null) {
              return null;
            }
            data = maybeData;
          } else {
            data = updatedata;
          }
          final newState = decodeState(data);
          return newState;
        }
        return null;
      };

  static WatchFunction _makeWatchFunction() => (record) async {
        final defaultSubkey = record.subkeyOrDefault(-1);
        await record.watch(subkeys: [ValueSubkeyRange.single(defaultSubkey)]);
      };

  Future<void> refreshDefault() async {
    await initWait();

    final defaultSubkey = record.subkeyOrDefault(-1);
    await refresh([ValueSubkeyRange(low: defaultSubkey, high: defaultSubkey)]);
  }
}
