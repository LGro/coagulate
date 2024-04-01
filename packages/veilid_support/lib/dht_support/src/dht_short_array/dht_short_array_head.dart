part of 'dht_short_array.dart';

class _DHTShortArrayHead {
  _DHTShortArrayHead({required DHTRecord headRecord})
      : _headRecord = headRecord,
        _linkedRecords = [],
        _index = [],
        _free = [],
        _seqs = [],
        _localSeqs = [] {
    _calculateStride();
  }

  void _calculateStride() {
    switch (_headRecord.schema) {
      case DHTSchemaDFLT(oCnt: final oCnt):
        if (oCnt <= 1) {
          throw StateError('Invalid DFLT schema in DHTShortArray');
        }
        _stride = oCnt - 1;
      case DHTSchemaSMPL(oCnt: final oCnt, members: final members):
        if (oCnt != 0 || members.length != 1 || members[0].mCnt <= 1) {
          throw StateError('Invalid SMPL schema in DHTShortArray');
        }
        _stride = members[0].mCnt - 1;
    }
    assert(_stride <= DHTShortArray.maxElements, 'stride too long');
  }

  proto.DHTShortArray _toProto() {
    assert(_headMutex.isLocked, 'should be in mutex here');

    final head = proto.DHTShortArray();
    head.keys.addAll(_linkedRecords.map((lr) => lr.key.toProto()));
    head.index = List.of(_index);
    head.seqs.addAll(_seqs);
    // Do not serialize free list, it gets recreated
    // Do not serialize local seqs, they are only locally relevant
    return head;
  }

  TypedKey get recordKey => _headRecord.key;
  OwnedDHTRecordPointer get recordPointer => _headRecord.ownedDHTRecordPointer;
  int get length => _index.length;

  Future<void> close() async {
    final futures = <Future<void>>[_headRecord.close()];
    for (final lr in _linkedRecords) {
      futures.add(lr.close());
    }
    await Future.wait(futures);
  }

  Future<T> operate<T>(Future<T> Function(_DHTShortArrayHead) closure) async =>
      // ignore: prefer_expression_function_bodies
      _headMutex.protect(() async {
        return closure(this);
      });

  Future<(T?, bool)> operateWrite<T>(
          Future<T?> Function(_DHTShortArrayHead) closure) async =>
      _headMutex.protect(() async {
        final oldLinkedRecords = List.of(_linkedRecords);
        final oldIndex = List.of(_index);
        final oldFree = List.of(_free);
        final oldSeqs = List.of(_seqs);
        try {
          final out = await closure(this);
          // Write head assuming it has been changed
          if (!await _writeHead()) {
            // Failed to write head means head got overwritten so write should
            // be considered failed
            return (null, false);
          }

          onUpdatedHead?.call();
          return (out, true);
        } on Exception {
          // Exception means state needs to be reverted
          _linkedRecords = oldLinkedRecords;
          _index = oldIndex;
          _free = oldFree;
          _seqs = oldSeqs;

          rethrow;
        }
      });

  Future<void> operateWriteEventual(
      Future<bool> Function(_DHTShortArrayHead) closure,
      {Duration? timeout}) async {
    final timeoutTs = timeout == null
        ? null
        : Veilid.instance.now().offset(TimestampDuration.fromDuration(timeout));

    await _headMutex.protect(() async {
      late List<DHTRecord> oldLinkedRecords;
      late List<int> oldIndex;
      late List<int> oldFree;
      late List<int> oldSeqs;

      try {
        // Iterate until we have a successful element and head write

        do {
          // Save off old values each pass of tryWriteHead because the head
          // will have changed
          oldLinkedRecords = List.of(_linkedRecords);
          oldIndex = List.of(_index);
          oldFree = List.of(_free);
          oldSeqs = List.of(_seqs);

          // Try to do the element write
          while (true) {
            if (timeoutTs != null) {
              final now = Veilid.instance.now();
              if (now >= timeoutTs) {
                throw TimeoutException('timeout reached');
              }
            }
            if (await closure(this)) {
              break;
            }
            // Failed to write in closure resets state
            _linkedRecords = List.of(oldLinkedRecords);
            _index = List.of(oldIndex);
            _free = List.of(oldFree);
            _seqs = List.of(oldSeqs);
          }

          // Try to do the head write
        } while (!await _writeHead());

        onUpdatedHead?.call();
      } on Exception {
        // Exception means state needs to be reverted
        _linkedRecords = oldLinkedRecords;
        _index = oldIndex;
        _free = oldFree;
        _seqs = oldSeqs;

        rethrow;
      }
    });
  }

  /// Serialize and write out the current head record, possibly updating it
  /// if a newer copy is available online. Returns true if the write was
  /// successful
  Future<bool> _writeHead() async {
    assert(_headMutex.isLocked, 'should be in mutex here');

    final headBuffer = _toProto().writeToBuffer();

    final existingData = await _headRecord.tryWriteBytes(headBuffer);
    if (existingData != null) {
      // Head write failed, incorporate update
      await _updateHead(proto.DHTShortArray.fromBuffer(existingData));
      return false;
    }

    return true;
  }

  /// Validate a new head record that has come in from the network
  Future<void> _updateHead(proto.DHTShortArray head) async {
    assert(_headMutex.isLocked, 'should be in mutex here');

    // Get the set of new linked keys and validate it
    final updatedLinkedKeys = head.keys.map((p) => p.toVeilid()).toList();
    final updatedIndex = List.of(head.index);
    final updatedSeqs = List.of(head.seqs);
    final updatedFree = _makeFreeList(updatedLinkedKeys, updatedIndex);

    // See which records are actually new
    final oldRecords = Map<TypedKey, DHTRecord>.fromEntries(
        _linkedRecords.map((lr) => MapEntry(lr.key, lr)));
    final newRecords = <TypedKey, DHTRecord>{};
    final sameRecords = <TypedKey, DHTRecord>{};
    final updatedLinkedRecords = <DHTRecord>[];
    try {
      for (var n = 0; n < updatedLinkedKeys.length; n++) {
        final newKey = updatedLinkedKeys[n];
        final oldRecord = oldRecords[newKey];
        if (oldRecord == null) {
          // Open the new record
          final newRecord = await _openLinkedRecord(newKey);
          newRecords[newKey] = newRecord;
          updatedLinkedRecords.add(newRecord);
        } else {
          sameRecords[newKey] = oldRecord;
          updatedLinkedRecords.add(oldRecord);
        }
      }
    } on Exception catch (_) {
      // On any exception close the records we have opened
      await Future.wait(newRecords.entries.map((e) => e.value.close()));
      rethrow;
    }

    // From this point forward we should not throw an exception or everything
    // is possibly invalid. Just pass the exception up it happens and the caller
    // will have to delete this short array and reopen it if it can
    await oldRecords.entries
        .where((e) => !sameRecords.containsKey(e.key))
        .map((e) => e.value.close())
        .wait;

    // Get the localseqs list from inspect results
    final localReports = await [_headRecord, ...updatedLinkedRecords].map((r) {
      final start = (r.key == _headRecord.key) ? 1 : 0;
      return r.inspect(
          subkeys: [ValueSubkeyRange.make(start, start + _stride - 1)]);
    }).wait;
    final updatedLocalSeqs =
        localReports.map((l) => l.localSeqs).expand((e) => e).toList();

    // Make the new head cache
    _linkedRecords = updatedLinkedRecords;
    _index = updatedIndex;
    _free = updatedFree;
    _seqs = updatedSeqs;
    _localSeqs = updatedLocalSeqs;
  }

  // Pull the latest or updated copy of the head record from the network
  Future<bool> _loadHead(
      {bool forceRefresh = true, bool onlyUpdates = false}) async {
    // Get an updated head record copy if one exists
    final head = await _headRecord.getProtobuf(proto.DHTShortArray.fromBuffer,
        subkey: 0, forceRefresh: forceRefresh, onlyUpdates: onlyUpdates);
    if (head == null) {
      if (onlyUpdates) {
        // No update
        return false;
      }
      throw StateError('head missing during refresh');
    }

    await _updateHead(head);

    return true;
  }

  /////////////////////////////////////////////////////////////////////////////
  // Linked record management

  Future<DHTRecord> _getOrCreateLinkedRecord(int recordNumber) async {
    if (recordNumber == 0) {
      return _headRecord;
    }
    final pool = DHTRecordPool.instance;
    recordNumber--;
    while (recordNumber >= _linkedRecords.length) {
      // Linked records must use SMPL schema so writer can be specified
      // Use the same writer as the head record
      final smplWriter = _headRecord.writer!;
      final parent = _headRecord.key;
      final routingContext = _headRecord.routingContext;
      final crypto = _headRecord.crypto;

      final schema = DHTSchema.smpl(
          oCnt: 0,
          members: [DHTSchemaMember(mKey: smplWriter.key, mCnt: _stride)]);
      final dhtRecord = await pool.create(
          parent: parent,
          routingContext: routingContext,
          schema: schema,
          crypto: crypto,
          writer: smplWriter);

      // Add to linked records
      _linkedRecords.add(dhtRecord);
    }
    if (!await _writeHead()) {
      throw StateError('failed to add linked record');
    }
    return _linkedRecords[recordNumber];
  }

  /// Open a linked record for reading or writing, same as the head record
  Future<DHTRecord> _openLinkedRecord(TypedKey recordKey) async {
    final writer = _headRecord.writer;
    return (writer != null)
        ? await DHTRecordPool.instance.openWrite(
            recordKey,
            writer,
            parent: _headRecord.key,
            routingContext: _headRecord.routingContext,
          )
        : await DHTRecordPool.instance.openRead(
            recordKey,
            parent: _headRecord.key,
            routingContext: _headRecord.routingContext,
          );
  }

  Future<(DHTRecord, int)> lookupPosition(int pos) async {
    final idx = _index[pos];
    return lookupIndex(idx);
  }

  Future<(DHTRecord, int)> lookupIndex(int idx) async {
    final recordNumber = idx ~/ _stride;
    final record = await _getOrCreateLinkedRecord(recordNumber);
    final recordSubkey = (idx % _stride) + ((recordNumber == 0) ? 1 : 0);
    return (record, recordSubkey);
  }

  /////////////////////////////////////////////////////////////////////////////
  // Index management

  /// Allocate an empty index slot at a specific position
  void allocateIndex(int pos) {
    // Allocate empty index
    final idx = _emptyIndex();
    _index.insert(pos, idx);
  }

  int _emptyIndex() {
    if (_free.isNotEmpty) {
      return _free.removeLast();
    }
    if (_index.length == DHTShortArray.maxElements) {
      throw StateError('too many elements');
    }
    return _index.length;
  }

  void swapIndex(int aPos, int bPos) {
    if (aPos == bPos) {
      return;
    }
    final aIdx = _index[aPos];
    final bIdx = _index[bPos];
    _index[aPos] = bIdx;
    _index[bPos] = aIdx;
  }

  void clearIndex() {
    _index.clear();
    _free.clear();
  }

  /// Release an index at a particular position
  void freeIndex(int pos) {
    final idx = _index.removeAt(pos);
    _free.add(idx);
    // xxx: free list optimization here?
  }

  /// Validate the head from the DHT is properly formatted
  /// and calculate the free list from it while we're here
  List<int> _makeFreeList(
      List<Typed<FixedEncodedString43>> linkedKeys, List<int> index) {
    // Ensure nothing is duplicated in the linked keys set
    final newKeys = linkedKeys.toSet();
    assert(
        newKeys.length <=
            (DHTShortArray.maxElements + (_stride - 1)) ~/ _stride,
        'too many keys');
    assert(newKeys.length == linkedKeys.length, 'duplicated linked keys');
    final newIndex = index.toSet();
    assert(newIndex.length <= DHTShortArray.maxElements, 'too many indexes');
    assert(newIndex.length == index.length, 'duplicated index locations');

    // Ensure all the index keys fit into the existing records
    final indexCapacity = (linkedKeys.length + 1) * _stride;
    int? maxIndex;
    for (final idx in newIndex) {
      assert(idx >= 0 || idx < indexCapacity, 'index out of range');
      if (maxIndex == null || idx > maxIndex) {
        maxIndex = idx;
      }
    }

    // Figure out which indices are free
    final free = <int>[];
    if (maxIndex != null) {
      for (var i = 0; i < maxIndex; i++) {
        if (!newIndex.contains(i)) {
          free.add(i);
        }
      }
    }
    return free;
  }

  /// Check if we know that the network has a copy of an index that is newer
  /// than our local copy from looking at the seqs list in the head
  bool positionNeedsRefresh(int pos) {
    final idx = _index[pos];

    // If our local sequence number is unknown or hasnt been written yet
    // then a normal DHT operation is going to pull from the network anyway
    if (_localSeqs.length < idx || _localSeqs[idx] == 0xFFFFFFFF) {
      return false;
    }

    // If the remote sequence number record is unknown or hasnt been written
    // at this index yet, then we also do not refresh at this time as it
    // is the first time the index is being written to
    if (_seqs.length < idx || _seqs[idx] == 0xFFFFFFFF) {
      return false;
    }

    return _localSeqs[idx] < _seqs[idx];
  }

  /// Update the sequence number for a particular index in
  /// our local sequence number list.
  /// If a write is happening, update the network copy as well.
  Future<void> updatePositionSeq(int pos, bool write) async {
    final idx = _index[pos];
    final (record, recordSubkey) = await lookupIndex(idx);
    final report =
        await record.inspect(subkeys: [ValueSubkeyRange.single(recordSubkey)]);

    while (_localSeqs.length <= idx) {
      _localSeqs.add(0xFFFFFFFF);
    }
    _localSeqs[idx] = report.localSeqs[0];
    if (write) {
      while (_seqs.length <= idx) {
        _seqs.add(0xFFFFFFFF);
      }
      _seqs[idx] = report.localSeqs[0];
    }
  }

  /////////////////////////////////////////////////////////////////////////////
  // Watch For Updates

  // Watch head for changes
  Future<void> watch() async {
    // This will update any existing watches if necessary
    try {
      await _headRecord.watch(subkeys: [ValueSubkeyRange.single(0)]);

      // Update changes to the head record
      // Don't watch for local changes because this class already handles
      // notifying listeners and knows when it makes local changes
      _subscription ??=
          await _headRecord.listen(localChanges: false, _onHeadValueChanged);
    } on Exception {
      // If anything fails, try to cancel the watches
      await cancelWatch();
      rethrow;
    }
  }

  // Stop watching for changes to head and linked records
  Future<void> cancelWatch() async {
    await _headRecord.cancelWatch();
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _onHeadValueChanged(
      DHTRecord record, Uint8List? data, List<ValueSubkeyRange> subkeys) async {
    // If head record subkey zero changes, then the layout
    // of the dhtshortarray has changed
    if (data == null) {
      throw StateError('head value changed without data');
    }
    if (record.key != _headRecord.key ||
        subkeys.length != 1 ||
        subkeys[0] != ValueSubkeyRange.single(0)) {
      throw StateError('watch returning wrong subkey range');
    }

    // Decode updated head
    final headData = proto.DHTShortArray.fromBuffer(data);

    // Then update the head record
    await _headMutex.protect(() async {
      await _updateHead(headData);
      onUpdatedHead?.call();
    });
  }

  ////////////////////////////////////////////////////////////////////////////

  // Head/element mutex to ensure we keep the representation valid
  final Mutex _headMutex = Mutex();
  // Subscription to head record internal changes
  StreamSubscription<DHTRecordWatchChange>? _subscription;
  // Notify closure for external head changes
  void Function()? onUpdatedHead;

  // Head DHT record
  final DHTRecord _headRecord;
  // How many elements per linked record
  late final int _stride;

  // List of additional records after the head record used for element data
  List<DHTRecord> _linkedRecords;
  // Ordering of the subkey indices.
  // Elements are subkey numbers. Represents the element order.
  List<int> _index;
  // List of free subkeys for elements that have been removed.
  // Used to optimize allocations.
  List<int> _free;
  // The sequence numbers of each subkey.
  // Index is by subkey number not by element index.
  // (n-1 for head record and then the next n for linked records)
  List<int> _seqs;
  // The local sequence numbers for each subkey.
  List<int> _localSeqs;
}
