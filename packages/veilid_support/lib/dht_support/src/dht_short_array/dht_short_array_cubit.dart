import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../../../veilid_support.dart';

typedef DHTShortArrayState<T> = AsyncValue<IList<OnlineElementState<T>>>;
typedef DHTShortArrayCubitState<T> = BlocBusyState<DHTShortArrayState<T>>;

class DHTShortArrayCubit<T> extends Cubit<DHTShortArrayCubitState<T>>
    with BlocBusyWrapper<DHTShortArrayState<T>>, RefreshableCubit {
  DHTShortArrayCubit({
    required Future<DHTShortArray> Function() open,
    required T Function(List<int> data) decodeElement,
  })  : _decodeElement = decodeElement,
        super(const BlocBusyState(AsyncValue.loading())) {
    _initWait.add((cancel) async {
      try {
        // Do record open/create
        while (!cancel.isCompleted) {
          try {
            // Open DHT record
            _shortArray = await open();
            _wantsCloseRecord = true;
            break;
          } on DHTExceptionNotAvailable {
            // Wait for a bit
            await asyncSleep();
          }
        }
      } on Exception catch (e, st) {
        addError(e, st);
        emit(DHTShortArrayCubitState<T>(AsyncValue.error(e, st)));
        return;
      }

      // Kick off initial update
      _update();

      // Subscribe to changes
      _subscription = await _shortArray.listen(_update);
    });
  }

  @override
  Future<void> refresh({bool forceRefresh = false}) async {
    await _initWait();
    await _refreshNoWait(forceRefresh: forceRefresh);
  }

  Future<void> _refreshNoWait({bool forceRefresh = false}) async =>
      busy((emit) async => _refreshInner(emit, forceRefresh: forceRefresh));

  Future<void> _refreshInner(void Function(DHTShortArrayState<T>) emit,
      {bool forceRefresh = false}) async {
    try {
      final newState = await _shortArray.operate((reader) async {
        // If this is writeable get the offline positions
        Set<int>? offlinePositions;
        if (_shortArray.writer != null) {
          offlinePositions = await reader.getOfflinePositions();
        }

        // Get the items
        final allItems = (await reader.getRange(0, forceRefresh: forceRefresh))
            ?.indexed
            .map((x) => OnlineElementState(
                value: _decodeElement(x.$2),
                isOffline: offlinePositions?.contains(x.$1) ?? false))
            .toIList();
        return allItems;
      });
      if (newState == null) {
        // Mark us as needing refresh
        setWantsRefresh();
        return;
      }
      emit(AsyncValue.data(newState));
      setRefreshed();
    } on Exception catch (e, st) {
      addError(e, st);
      emit(AsyncValue.error(e, st));
    }
  }

  void _update() {
    // Run at most one background update process
    // Because this is async, we could get an update while we're
    // still processing the last one.
    // Only called after init future has run, or during it
    // so we dont have to wait for that here.
    _sspUpdate.busyUpdate<T, DHTShortArrayState<T>>(
        busy, (emit) async => _refreshInner(emit));
  }

  @override
  Future<void> close() async {
    await _initWait(cancelValue: true);
    await _subscription?.cancel();
    _subscription = null;
    if (_wantsCloseRecord) {
      await _shortArray.close();
    }
    await super.close();
  }

  Future<R> operate<R>(
      Future<R> Function(DHTShortArrayReadOperations) closure) async {
    await _initWait();
    return _shortArray.operate(closure);
  }

  Future<R> operateWrite<R>(
      Future<R> Function(DHTShortArrayWriteOperations) closure) async {
    await _initWait();
    return _shortArray.operateWrite(closure);
  }

  Future<R> operateWriteEventual<R>(
      Future<R> Function(DHTShortArrayWriteOperations) closure,
      {Duration? timeout}) async {
    await _initWait();
    return _shortArray.operateWriteEventual(closure, timeout: timeout);
  }

  final WaitSet<void, bool> _initWait = WaitSet();
  late final DHTShortArray _shortArray;
  final T Function(List<int> data) _decodeElement;
  StreamSubscription<void>? _subscription;
  bool _wantsCloseRecord = false;
  final _sspUpdate = SingleStatelessProcessor();
}
