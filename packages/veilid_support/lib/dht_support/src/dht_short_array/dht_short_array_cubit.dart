import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_tools/bloc_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mutex/mutex.dart';

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
    _initFuture = Future(() async {
      // Open DHT record
      _shortArray = await open();
      _wantsCloseRecord = true;

      // Make initial state update
      unawaited(_refreshNoWait());
      _subscription = await _shortArray.listen(_update);
    });
  }

  DHTShortArrayCubit.value({ 
    required DHTShortArray shortArray,
    required T Function(List<int> data) decodeElement,
  })  : _shortArray = shortArray,
        _decodeElement = decodeElement,
        super(const BlocBusyState(AsyncValue.loading())) {
    _initFuture = Future(() async {
      // Make initial state update
      unawaited(_refreshNoWait());
      _subscription = await shortArray.listen(_update);
    });
  }

  Future<void> refresh({bool forceRefresh = false}) async {
    await _initFuture;
    await _refreshNoWait(forceRefresh: forceRefresh);
  }

  Future<void> _refreshNoWait({bool forceRefresh = false}) async =>
      busy((emit) async => _operateMutex.protect(
          () async => _refreshInner(emit, forceRefresh: forceRefresh)));

  Future<void> _refreshInner(void Function(AsyncValue<IList<T>>) emit,
      {bool forceRefresh = false}) async {
    try {
      final newState =
          (await _shortArray.getAllItems(forceRefresh: forceRefresh))
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
    _sspUpdate.busyUpdate<T, AsyncValue<IList<T>>>(busy,
        (emit) async => _operateMutex.protect(() async => _refreshInner(emit)));
  }

  @override
  Future<void> close() async {
    await _initFuture;
    await _subscription?.cancel();
    _subscription = null;
    if (_wantsCloseRecord) {
      await _shortArray.close();
    }
    await super.close();
  }

  Future<R?> operate<R>(Future<R?> Function(DHTShortArray) closure) async {
    await _initFuture;
    return _operateMutex.protect(() async => closure(_shortArray));
  }

  final _operateMutex = Mutex();
  late final Future<void> _initFuture;
  late final DHTShortArray _shortArray;
  final T Function(List<int> data) _decodeElement;
  StreamSubscription<void>? _subscription;
  bool _wantsCloseRecord = false;
  final _sspUpdate = SingleStatelessProcessor();
}
