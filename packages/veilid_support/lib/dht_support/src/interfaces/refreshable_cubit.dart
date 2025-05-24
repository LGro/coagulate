abstract mixin class RefreshableCubit {
  Future<void> refresh({bool forceRefresh = false});

  void setWantsRefresh() {
    _wantsRefresh = true;
  }

  void setRefreshed() {
    _wantsRefresh = false;
  }

  bool get wantsRefresh => _wantsRefresh;

  ////////////////////////////////////////////////////////////////////////////
  bool _wantsRefresh = false;
}
