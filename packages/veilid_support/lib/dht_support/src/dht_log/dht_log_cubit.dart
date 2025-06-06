import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

import '../../../veilid_support.dart';

@immutable
class DHTLogStateData<T> extends Equatable {
  const DHTLogStateData(
      {required this.length,
      required this.window,
      required this.windowTail,
      required this.windowSize,
      required this.follow});
  // The total number of elements in the whole log
  final int length;
  // The view window of the elements in the dhtlog
  // Span is from [tail - window.length, tail)
  final IList<OnlineElementState<T>> window;
  // The position of the view window, one past the last element
  final int windowTail;
  // The total number of elements to try to keep in the window
  final int windowSize;
  // If we have the window following the log
  final bool follow;

  @override
  List<Object?> get props => [length, window, windowTail, windowSize, follow];

  @override
  String toString() => 'DHTLogStateData('
      'length: $length, '
      'windowTail: $windowTail, '
      'windowSize: $windowSize, '
      'follow: $follow, '
      'window: ${DynamicDebug.toDebug(window)})';
}

typedef DHTLogState<T> = AsyncValue<DHTLogStateData<T>>;
typedef DHTLogBusyState<T> = BlocBusyState<DHTLogState<T>>;

class DHTLogCubit<T> extends Cubit<DHTLogBusyState<T>>
    with BlocBusyWrapper<DHTLogState<T>>, RefreshableCubit {
  DHTLogCubit({
    required Future<DHTLog> Function() open,
    required T Function(List<int> data) decodeElement,
  })  : _decodeElement = decodeElement,
        super(const BlocBusyState(AsyncValue.loading())) {
    _initWait.add((cancel) async {
      try {
        // Do record open/create
        while (!cancel.isCompleted) {
          try {
            // Open DHT record
            _log = await open();
            _wantsCloseRecord = true;
            break;
          } on DHTExceptionNotAvailable {
            // Wait for a bit
            await asyncSleep();
          }
        }
      } on Exception catch (e, st) {
        addError(e, st);
        emit(DHTLogBusyState(AsyncValue.error(e, st)));
        return;
      }
      // Make initial state update
      _initialUpdate();
      _subscription = await _log.listen(_update);
    });
  }

  // Set the tail position of the log for pagination.
  // If tail is 0, the end of the log is used.
  // If tail is negative, the position is subtracted from the current log
  // length.
  // If tail is positive, the position is absolute from the head of the log
  // If follow is enabled, the tail offset will update when the log changes
  Future<void> setWindow(
      {int? windowTail,
      int? windowSize,
      bool? follow,
      bool forceRefresh = false}) async {
    await _initWait();
    if (windowTail != null) {
      _windowTail = windowTail;
    }
    if (windowSize != null) {
      _windowSize = windowSize;
    }
    if (follow != null) {
      _follow = follow;
    }
    await _refreshNoWait(forceRefresh: forceRefresh);
  }

  @override
  Future<void> refresh({bool forceRefresh = false}) async {
    await _initWait();
    await _refreshNoWait(forceRefresh: forceRefresh);
  }

  Future<void> _refreshNoWait({bool forceRefresh = false}) async =>
      busy((emit) async => _refreshInner(emit, forceRefresh: forceRefresh));

  Future<void> _refreshInner(void Function(AsyncValue<DHTLogStateData<T>>) emit,
      {bool forceRefresh = false}) async {
    late final int length;
    final windowElements = await _log.operate((reader) async {
      length = reader.length;
      return _loadElementsFromReader(reader, _windowTail, _windowSize);
    });
    if (windowElements == null) {
      setWantsRefresh();
      return;
    }

    emit(AsyncValue.data(DHTLogStateData(
        length: length,
        window: windowElements.$2,
        windowTail: windowElements.$1 + windowElements.$2.length,
        windowSize: windowElements.$2.length,
        follow: _follow)));
    setRefreshed();
  }

  // Tail is one past the last element to load
  Future<(int, IList<OnlineElementState<T>>)?> _loadElementsFromReader(
      DHTLogReadOperations reader, int tail, int count,
      {bool forceRefresh = false}) async {
    final length = reader.length;
    final end = ((tail - 1) % length) + 1;
    final start = (count < end) ? end - count : 0;
    if (length == 0) {
      return (start, IList<OnlineElementState<T>>.empty());
    }

    // If this is writeable get the offline positions
    Set<int>? offlinePositions;
    if (_log.writer != null) {
      offlinePositions = await reader.getOfflinePositions();
    }

    // Get the items
    final allItems = (await reader.getRange(start,
            length: end - start, forceRefresh: forceRefresh))
        ?.indexed
        .map((x) => OnlineElementState(
            value: _decodeElement(x.$2),
            isOffline: offlinePositions?.contains(x.$1) ?? false))
        .toIList();
    if (allItems == null) {
      return null;
    }

    return (start, allItems);
  }

  void _update(DHTLogUpdate upd) {
    // Run at most one background update process
    // Because this is async, we could get an update while we're
    // still processing the last one. Only called after init future has run
    // or during it, so we dont have to wait for that here.

    // Accumulate head and tail deltas
    _headDelta += upd.headDelta;
    _tailDelta += upd.tailDelta;

    _sspUpdate.busyUpdate<T, DHTLogState<T>>(busy, (emit) async {
      // apply follow
      if (_follow) {
        if (_windowTail <= 0) {
          // Negative tail is already following tail changes
        } else {
          // Positive tail is measured from the head, so apply deltas
          _windowTail = (_windowTail + _tailDelta - _headDelta) % upd.length;
        }
      } else {
        if (_windowTail <= 0) {
          // Negative tail is following tail changes so apply deltas
          var posTail = _windowTail + upd.length;
          posTail = (posTail + _tailDelta - _headDelta) % upd.length;
          _windowTail = posTail - upd.length;
        } else {
          // Positive tail is measured from head so not following tail
        }
      }
      _headDelta = 0;
      _tailDelta = 0;

      await _refreshInner(emit);
    });
  }

  void _initialUpdate() {
    _sspUpdate.busyUpdate<T, DHTLogState<T>>(busy, (emit) async {
      await _refreshInner(emit);
    });
  }

  @override
  Future<void> close() async {
    await _initWait(cancelValue: true);
    await _subscription?.cancel();
    _subscription = null;
    if (_wantsCloseRecord) {
      await _log.close();
    }
    await super.close();
  }

  Future<R> operate<R>(Future<R> Function(DHTLogReadOperations) closure) async {
    await _initWait();
    return _log.operate(closure);
  }

  Future<R> operateAppend<R>(
      Future<R> Function(DHTLogWriteOperations) closure) async {
    await _initWait();
    return _log.operateAppend(closure);
  }

  Future<R> operateAppendEventual<R>(
      Future<R> Function(DHTLogWriteOperations) closure,
      {Duration? timeout}) async {
    await _initWait();
    return _log.operateAppendEventual(closure, timeout: timeout);
  }

  final WaitSet<void, bool> _initWait = WaitSet();
  late final DHTLog _log;
  final T Function(List<int> data) _decodeElement;
  StreamSubscription<void>? _subscription;
  bool _wantsCloseRecord = false;
  final _sspUpdate = SingleStatelessProcessor();

  // Accumulated deltas since last update
  var _headDelta = 0;
  var _tailDelta = 0;

  // Cubit window into the DHTLog
  var _windowTail = 0;
  var _windowSize = DHTShortArray.maxElements;
  var _follow = true;
}
