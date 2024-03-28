part of 'dht_short_array.dart';

////////////////////////////////////////////////////////////////
// Internal Operations

class _DHTShortArrayHead {
  _DHTShortArrayHead({required this.headRecord})
      : linkedRecords = [],
        index = [],
        free = [],
        seqs = [],
        localSeqs = [] {
    _calculateStride();
  }

  proto.DHTShortArray toProto() {
    final head = proto.DHTShortArray();
    head.keys.addAll(linkedRecords.map((lr) => lr.key.toProto()));
    head.index.addAll(index);
    head.seqs.addAll(seqs);
    // Do not serialize free list, it gets recreated
    // Do not serialize local seqs, they are only locally relevant
    return head;
  }

  Future<void> close() async {
    final futures = <Future<void>>[headRecord.close()];
    for (final lr in linkedRecords) {
      futures.add(lr.close());
    }
    await Future.wait(futures);
  }

  Future<void> delete() async {
    final futures = <Future<void>>[headRecord.delete()];
    for (final lr in linkedRecords) {
      futures.add(lr.delete());
    }
    await Future.wait(futures);
  }

  Future<T> operate<T>(Future<T> Function(_DHTShortArrayHead) closure) async =>
      // ignore: prefer_expression_function_bodies
      _headMutex.protect(() async {
        return closure(this);
      });

  Future<T?> operateWrite<T>(
      Future<T> Function(_DHTShortArrayHead) closure) async {
    final oldLinkedRecords = List.of(linkedRecords);
    final oldIndex = List.of(index);
    final oldFree = List.of(free);
    final oldSeqs = List.of(seqs);
    try {
      final out = await _headMutex.protect(() async {
        final out = await closure(this);
        // Write head assuming it has been changed
        if (!await _tryWriteHead()) {
          // Failed to write head means head got overwritten so write should
          // be considered failed
          return null;
        }
        return out;
      });
      return out;
    } on Exception {
      // Exception means state needs to be reverted
      linkedRecords = oldLinkedRecords;
      index = oldIndex;
      free = oldFree;
      seqs = oldSeqs;

      rethrow;
    }
  }

  Future<void> operateWriteEventual(
      Future<bool> Function(_DHTShortArrayHead) closure,
      {Duration? timeout}) async {
    late List<DHTRecord> oldLinkedRecords;
    late List<int> oldIndex;
    late List<int> oldFree;
    late List<int> oldSeqs;

    final timeoutTs = timeout == null
        ? null
        : Veilid.instance.now().offset(TimestampDuration.fromDuration(timeout));
    try {
      await _headMutex.protect(() async {
        // Iterate until we have a successful element and head write
        do {
          // Save off old values each pass of tryWriteHead because the head
          // will have changed
          oldLinkedRecords = List.of(linkedRecords);
          oldIndex = List.of(index);
          oldFree = List.of(free);
          oldSeqs = List.of(seqs);

          // Try to do the element write
          do {
            if (timeoutTs != null) {
              final now = Veilid.instance.now();
              if (now >= timeoutTs) {
                throw TimeoutException('timeout reached');
              }
            }
          } while (!await closure(this));

          // Try to do the head write
        } while (!await _tryWriteHead());
      });
    } on Exception {
      // Exception means state needs to be reverted
      linkedRecords = oldLinkedRecords;
      index = oldIndex;
      free = oldFree;
      seqs = oldSeqs;

      rethrow;
    }
  }

  /// Serialize and write out the current head record, possibly updating it
  /// if a newer copy is available online. Returns true if the write was
  /// successful
  Future<bool> _tryWriteHead() async {
    final headBuffer = toProto().writeToBuffer();

    final existingData = await headRecord.tryWriteBytes(headBuffer);
    if (existingData != null) {
      // Head write failed, incorporate update
      await _updateHead(proto.DHTShortArray.fromBuffer(existingData));
      return false;
    }

    return true;
  }

  /// Validate a new head record that has come in from the network
  Future<void> _updateHead(proto.DHTShortArray head) async {
    // Get the set of new linked keys and validate it
    final updatedLinkedKeys = head.keys.map((p) => p.toVeilid()).toList();
    final updatedIndex = List.of(head.index);
    final updatedSeqs = List.of(head.seqs);
    final updatedFree = _makeFreeList(updatedLinkedKeys, updatedIndex);

    // See which records are actually new
    final oldRecords = Map<TypedKey, DHTRecord>.fromEntries(
        linkedRecords.map((lr) => MapEntry(lr.key, lr)));
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
    await Future.wait(oldRecords.entries
        .where((e) => !sameRecords.containsKey(e.key))
        .map((e) => e.value.close()));

    // Get the localseqs list from inspect results
    final localReports = await [headRecord, ...updatedLinkedRecords].map((r) {
      final start = (r.key == headRecord.key) ? 1 : 0;
      return r
          .inspect(subkeys: [ValueSubkeyRange.make(start, start + stride - 1)]);
    }).wait;
    final updatedLocalSeqs =
        localReports.map((l) => l.localSeqs).expand((e) => e).toList();

    // Make the new head cache
    linkedRecords = updatedLinkedRecords;
    index = updatedIndex;
    free = updatedFree;
    seqs = updatedSeqs;
    localSeqs = updatedLocalSeqs;
  }

  /// Pull the latest or updated copy of the head record from the network
  Future<bool> _refreshInner(
      {bool forceRefresh = true, bool onlyUpdates = false}) async {
    // Get an updated head record copy if one exists
    final head = await headRecord.getProtobuf(proto.DHTShortArray.fromBuffer,
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

  void _calculateStride() {
    switch (headRecord.schema) {
      case DHTSchemaDFLT(oCnt: final oCnt):
        if (oCnt <= 1) {
          throw StateError('Invalid DFLT schema in DHTShortArray');
        }
        stride = oCnt - 1;
      case DHTSchemaSMPL(oCnt: final oCnt, members: final members):
        if (oCnt != 0 || members.length != 1 || members[0].mCnt <= 1) {
          throw StateError('Invalid SMPL schema in DHTShortArray');
        }
        stride = members[0].mCnt - 1;
    }
    assert(stride <= DHTShortArray.maxElements, 'stride too long');
  }

  DHTRecord? getLinkedRecord(int recordNumber) {
    if (recordNumber == 0) {
      return headRecord;
    }
    recordNumber--;
    if (recordNumber >= linkedRecords.length) {
      return null;
    }
    return linkedRecords[recordNumber];
  }

  Future<DHTRecord> getOrCreateLinkedRecord(int recordNumber) async {
    if (recordNumber == 0) {
      return headRecord;
    }
    final pool = DHTRecordPool.instance;
    recordNumber--;
    while (recordNumber >= linkedRecords.length) {
      // Linked records must use SMPL schema so writer can be specified
      // Use the same writer as the head record
      final smplWriter = headRecord.writer!;
      final parent = pool.getParentRecordKey(headRecord.key);
      final routingContext = headRecord.routingContext;
      final crypto = headRecord.crypto;

      final schema = DHTSchema.smpl(
          oCnt: 0,
          members: [DHTSchemaMember(mKey: smplWriter.key, mCnt: stride)]);
      final dhtCreateRecord = await pool.create(
          parent: parent,
          routingContext: routingContext,
          schema: schema,
          crypto: crypto,
          writer: smplWriter);
      // Reopen with SMPL writer
      await dhtCreateRecord.close();
      final dhtRecord = await pool.openWrite(dhtCreateRecord.key, smplWriter,
          parent: parent, routingContext: routingContext, crypto: crypto);

      // Add to linked records
      linkedRecords.add(dhtRecord);
      if (!await _tryWriteHead()) {
        await _refreshInner();
      }
    }
    return linkedRecords[recordNumber];
  }

  int emptyIndex() {
    if (free.isNotEmpty) {
      return free.removeLast();
    }
    if (index.length == DHTShortArray.maxElements) {
      throw StateError('too many elements');
    }
    return index.length;
  }

  void freeIndex(int idx) {
    free.add(idx);
    // xxx: free list optimization here?
  }

  /// Validate the head from the DHT is properly formatted
  /// and calculate the free list from it while we're here
  List<int> _makeFreeList(
      List<Typed<FixedEncodedString43>> linkedKeys, List<int> index) {
    // Ensure nothing is duplicated in the linked keys set
    final newKeys = linkedKeys.toSet();
    assert(
        newKeys.length <= (DHTShortArray.maxElements + (stride - 1)) ~/ stride,
        'too many keys');
    assert(newKeys.length == linkedKeys.length, 'duplicated linked keys');
    final newIndex = index.toSet();
    assert(newIndex.length <= DHTShortArray.maxElements, 'too many indexes');
    assert(newIndex.length == index.length, 'duplicated index locations');

    // Ensure all the index keys fit into the existing records
    final indexCapacity = (linkedKeys.length + 1) * stride;
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

  /// Open a linked record for reading or writing, same as the head record
  Future<DHTRecord> _openLinkedRecord(TypedKey recordKey) async {
    final writer = headRecord.writer;
    return (writer != null)
        ? await DHTRecordPool.instance.openWrite(
            recordKey,
            writer,
            parent: headRecord.key,
            routingContext: headRecord.routingContext,
          )
        : await DHTRecordPool.instance.openRead(
            recordKey,
            parent: headRecord.key,
            routingContext: headRecord.routingContext,
          );
  }

  /// Check if we know that the network has a copy of an index that is newer
  /// than our local copy from looking at the seqs list in the head
  bool indexNeedsRefresh(int index) {
    // If our local sequence number is unknown or hasnt been written yet
    // then a normal DHT operation is going to pull from the network anyway
    if (localSeqs.length < index || localSeqs[index] == 0xFFFFFFFF) {
      return false;
    }

    // If the remote sequence number record is unknown or hasnt been written
    // at this index yet, then we also do not refresh at this time as it
    // is the first time the index is being written to
    if (seqs.length < index || seqs[index] == 0xFFFFFFFF) {
      return false;
    }

    return localSeqs[index] < seqs[index];
  }

  /// Update the sequence number for a particular index in
  /// our local sequence number list.
  /// If a write is happening, update the network copy as well.
  Future<void> updateIndexSeq(int index, bool write) async {
    final recordNumber = index ~/ stride;
    final record = await getOrCreateLinkedRecord(recordNumber);
    final recordSubkey = (index % stride) + ((recordNumber == 0) ? 1 : 0);
    final report =
        await record.inspect(subkeys: [ValueSubkeyRange.single(recordSubkey)]);

    while (localSeqs.length <= index) {
      localSeqs.add(0xFFFFFFFF);
    }
    localSeqs[index] = report.localSeqs[0];
    if (write) {
      while (seqs.length <= index) {
        seqs.add(0xFFFFFFFF);
      }
      seqs[index] = report.localSeqs[0];
    }
  }

  // Watch head for changes
  Future<void> _watch() async {
    // This will update any existing watches if necessary
    try {
      await headRecord.watch(subkeys: [ValueSubkeyRange.single(0)]);

      // Update changes to the head record
      // Don't watch for local changes because this class already handles
      // notifying listeners and knows when it makes local changes
      _subscription ??=
          await headRecord.listen(localChanges: false, _onUpdateHead);
    } on Exception {
      // If anything fails, try to cancel the watches
      await _cancelWatch();
      rethrow;
    }
  }

  // Stop watching for changes to head and linked records
  Future<void> _cancelWatch() async {
    await headRecord.cancelWatch();
    await _subscription?.cancel();
    _subscription = null;
  }

  // Called when a head or linked record changes
  Future<void> _onUpdateHead(
      DHTRecord record, Uint8List? data, List<ValueSubkeyRange> subkeys) async {
    // If head record subkey zero changes, then the layout
    // of the dhtshortarray has changed
    var updateHead = false;
    if (record == headRecord && subkeys.containsSubkey(0)) {
      updateHead = true;
    }

    // If we have any other subkeys to update, do them first
    final unord = List<Future<Uint8List?>>.empty(growable: true);
    for (final skr in subkeys) {
      for (var subkey = skr.low; subkey <= skr.high; subkey++) {
        // Skip head subkey
        if (updateHead && subkey == 0) {
          continue;
        }
        // Get the subkey, which caches the result in the local record store
        unord.add(record.get(subkey: subkey, forceRefresh: true));
      }
    }
    await unord.wait;

    // Then update the head record
    if (updateHead) {
      await _refreshInner(forceRefresh: false);
    }
  }

  ////////////////////////////////////////////////////////////////////////////

  // Head/element mutex to ensure we keep the representation valid
  final Mutex _headMutex = Mutex();
  // Subscription to head record internal changes
  StreamSubscription<DHTRecordWatchChange>? _subscription;

  // Head DHT record
  final DHTRecord headRecord;
  // How many elements per linked record
  late final int stride;

// List of additional records after the head record used for element data
  List<DHTRecord> linkedRecords;

  // Ordering of the subkey indices.
  // Elements are subkey numbers. Represents the element order.
  List<int> index;
  // List of free subkeys for elements that have been removed.
  // Used to optimize allocations.
  List<int> free;
  // The sequence numbers of each subkey.
  // Index is by subkey number not by element index.
  // (n-1 for head record and then the next n for linked records)
  List<int> seqs;
  // The local sequence numbers for each subkey.
  List<int> localSeqs;
}
