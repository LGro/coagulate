class DelayedWaitSet {
  DelayedWaitSet();

  void add(Future<void> Function() closure) {
    _closures.add(closure);
  }

  Future<void> call() async {
    final futures = _closures.map((c) => c()).toList();
    _closures = [];
    if (futures.isEmpty) {
      return;
    }
    await futures.wait;
  }

  List<Future<void> Function()> _closures = [];
}
