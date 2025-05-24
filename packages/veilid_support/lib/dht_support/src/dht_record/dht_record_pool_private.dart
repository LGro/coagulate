part of 'dht_record_pool.dart';

// DHT crypto domain
const String _cryptoDomainDHT = 'dht';

// Singlefuture keys
const _sfPollWatch = '_pollWatch';
const _sfListen = 'listen';

/// Watch state
@immutable
class _WatchState extends Equatable {
  const _WatchState({
    required this.subkeys,
    required this.expiration,
    required this.count,
  });
  final List<ValueSubkeyRange>? subkeys;
  final Timestamp? expiration;
  final int? count;

  @override
  List<Object?> get props => [subkeys, expiration, count];
}

/// Data shared amongst all DHTRecord instances
class _SharedDHTRecordData {
  _SharedDHTRecordData(
      {required this.recordDescriptor,
      required this.defaultWriter,
      required this.defaultRoutingContext});
  DHTRecordDescriptor recordDescriptor;
  KeyPair? defaultWriter;
  VeilidRoutingContext defaultRoutingContext;
  bool needsWatchStateUpdate = false;
  _WatchState? unionWatchState;
}

// Per opened record data
class _OpenedRecordInfo {
  _OpenedRecordInfo(
      {required DHTRecordDescriptor recordDescriptor,
      required KeyPair? defaultWriter,
      required VeilidRoutingContext defaultRoutingContext})
      : shared = _SharedDHTRecordData(
            recordDescriptor: recordDescriptor,
            defaultWriter: defaultWriter,
            defaultRoutingContext: defaultRoutingContext);
  _SharedDHTRecordData shared;
  Set<DHTRecord> records = {};

  String get debugNames {
    final r = records.toList()
      ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
    return '[${r.map((x) => x.debugName).join(',')}]';
  }

  String get details {
    final r = records.toList()
      ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
    return '[${r.map((x) => "writer=${x._writer} "
        "defaultSubkey=${x._defaultSubkey}").join(',')}]';
  }

  String get sharedDetails => shared.toString();
}
