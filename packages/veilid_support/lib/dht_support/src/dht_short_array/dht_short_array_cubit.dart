import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_tools/bloc_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../../../veilid_support.dart';

typedef DHTShortArrayState<T> = AsyncValue<IList<T>>;
typedef DHTShortArrayBusyState<T> = BlocBusyState<DHTShortArrayState<T>>;

class DHTShortArrayCubit<T> extends Cubit<DHTShortArrayBusyState<T>>
    with BlocBusyWrapper<DHTShortArrayState<T>> {
  DHTShortArrayCubit({
    required Future<DHTShortArray> Function() open,
    required T Function(List<int> data) decodeElement,
  })  : _decodeElement = decodeElement,
        super(const BlocBusyState(AsyncValue.loading())) {
    _initWait.add(() async {
      // Open DHT record
      _shortArray = await open();
      _wantsCloseRecord = true;

      // Make initial state update
      await _refreshNoWait();
      _subscription = await _shortArray.listen(_update);
    });
  }

  // DHTShortArrayCubit.value({
  //   required DHTShortArray shortArray,
  //   required T Function(List<int> data) decodeElement,
  // })  : _shortArray = shortArray,
  //       _decodeElement = decodeElement,
  //       super(const BlocBusyState(AsyncValue.loading())) {
  //   _initFuture = Future(() async {
  //     // Make initial state update
  //     unawaited(_refreshNoWait());
  //     _subscription = await shortArray.listen(_update);
  //   });
  // }

  Future<void> refresh({bool forceRefresh = false}) async {
    await _initWait();
    await _refreshNoWait(forceRefresh: forceRefresh);
  }

  Future<void> _refreshNoWait({bool forceRefresh = false}) async =>
      busy((emit) async => _refreshInner(emit, forceRefresh: forceRefresh));

  Future<void> _refreshInner(void Function(AsyncValue<IList<T>>) emit,
      {bool forceRefresh = false}) async {
    try {
      final newState = (await _shortArray.operate(
              (reader) => reader.getAllItems(forceRefresh: forceRefresh)))
          ?.map(_decodeElement)
          .toIList();
      if (newState != null) {
        emit(AsyncValue.data(newState));
      }
    } on Exception catch (e) {
      emit(AsyncValue.error(e));
    }
  }

  void _update() {
    // Run at most one background update process
    // Because this is async, we could get an update while we're
    // still processing the last one. Only called after init future has run
    // so we dont have to wait for that here.
    _sspUpdate.busyUpdate<T, DHTShortArrayState<T>>(
        busy, (emit) async => _refreshInner(emit));
  }

  @override
  Future<void> close() async {
    await _initWait();
    await _subscription?.cancel();
    _subscription = null;
    if (_wantsCloseRecord) {
      await _shortArray.close();
    }
    await super.close();
  }

  Future<R?> operate<R>(Future<R?> Function(DHTShortArrayRead) closure) async {
    await _initWait();
    return _shortArray.operate(closure);
  }

  Future<(R?, bool)> operateWrite<R>(
      Future<R?> Function(DHTShortArrayWrite) closure) async {
    await _initWait();
    return _shortArray.operateWrite(closure);
  }

  Future<void> operateWriteEventual(
      Future<bool> Function(DHTShortArrayWrite) closure,
      {Duration? timeout}) async {
    await _initWait();
    return _shortArray.operateWriteEventual(closure, timeout: timeout);
  }

  final WaitSet _initWait = WaitSet();
  late final DHTShortArray _shortArray;
  final T Function(List<int> data) _decodeElement;
  StreamSubscription<void>? _subscription;
  bool _wantsCloseRecord = false;
  final _sspUpdate = SingleStatelessProcessor();
}
