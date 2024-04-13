class WaitSet {
  WaitSet();

  void add(Future<void> Function() closure) {
    _futures.add(Future.delayed(Duration.zero, closure));
  }

  Future<void> call() async {
    final futures = _futures;
    _futures = [];
    if (futures.isEmpty) {
      return;
    }
    await futures.wait;
  }

  List<Future<void>> _futures = [];
}
