import 'dart:async';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../veilid_support.dart';

typedef InitialStateFunction<T> = Future<T?> Function(DHTRecord);
typedef StateFunction<T> = Future<T?> Function(
    DHTRecord, List<ValueSubkeyRange>, Uint8List?);
typedef WatchFunction = Future<void> Function(DHTRecord);

class DHTRecordCubit<T> extends Cubit<AsyncValue<T>> {
  DHTRecordCubit({
    required Future<DHTRecord> Function() open,
    required InitialStateFunction<T> initialStateFunction,
    required StateFunction<T> stateFunction,
    required WatchFunction watchFunction,
  })  : _wantsCloseRecord = false,
        _stateFunction = stateFunction,
        super(const AsyncValue.loading()) {
    initWait.add(() async {
      // Do record open/create
      _record = await open();
      _wantsCloseRecord = true;
      await _init(initialStateFunction, stateFunction, watchFunction);
    });
  }

  // DHTRecordCubit.value({
  //   required DHTRecord record,
  //   required InitialStateFunction<T> initialStateFunction,
  //   required StateFunction<T> stateFunction,
  //   required WatchFunction watchFunction,
  // })  : _record = record,
  //       _stateFunction = stateFunction,
  //       _wantsCloseRecord = false,
  //       super(const AsyncValue.loading()) {
  //   Future.delayed(Duration.zero, () async {
  //     await _init(initialStateFunction, stateFunction, watchFunction);
  //   });
  // }

  Future<void> _init(
    InitialStateFunction<T> initialStateFunction,
    StateFunction<T> stateFunction,
    WatchFunction watchFunction,
  ) async {
    // Make initial state update
    try {
      final initialState = await initialStateFunction(_record);
      if (initialState != null) {
        emit(AsyncValue.data(initialState));
      }
    } on Exception catch (e) {
      emit(AsyncValue.error(e));
    }

    _subscription = await _record.listen((record, data, subkeys) async {
      try {
        final newState = await stateFunction(record, subkeys, data);
        if (newState != null) {
          emit(AsyncValue.data(newState));
        }
      } on Exception catch (e) {
        emit(AsyncValue.error(e));
      }
    });

    await watchFunction(_record);
  }

  @override
  Future<void> close() async {
    await initWait();
    await _record.cancelWatch();
    await _subscription?.cancel();
    _subscription = null;
    if (_wantsCloseRecord) {
      await _record.close();
      _wantsCloseRecord = false;
    }
    await super.close();
  }

  Future<void> refresh(List<ValueSubkeyRange> subkeys) async {
    await initWait();

    var updateSubkeys = [...subkeys];

    for (final skr in subkeys) {
      for (var sk = skr.low; sk <= skr.high; sk++) {
        final data = await _record.get(
            subkey: sk, forceRefresh: true, onlyUpdates: true);
        if (data != null) {
          final newState = await _stateFunction(_record, updateSubkeys, data);
          if (newState != null) {
            // Emit the new state
            emit(AsyncValue.data(newState));
          }
          return;
        }
        // remove sk from update list
        // if we did not get an update for that subkey
        updateSubkeys = updateSubkeys.removeSubkey(sk);
      }
    }
  }

  DHTRecord get record => _record;

  @protected
  final WaitSet initWait = WaitSet();

  StreamSubscription<DHTRecordWatchChange>? _subscription;
  late DHTRecord _record;
  bool _wantsCloseRecord;
  final StateFunction<T> _stateFunction;
}
