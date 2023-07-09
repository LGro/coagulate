import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:veilid/veilid.dart';
import '../entities/entities.dart';

part 'active_logins_state.g.dart';

@riverpod
class ActiveLoginsState extends _$ActiveLoginsState {
  VeilidTableDB? _userLoginsTable;
  ActiveLogins _activeLogins;

  ActiveLoginsState() : _activeLogins = ActiveLogins.empty();

  @override
  FutureOr<ActiveLogins> build() async {
    _userLoginsTable ??= await Veilid.instance.openTableDB("login_state", 1);
    _activeLogins =
        (await _userLoginsTable!.loadStringJson(0, "active_logins") ??
            ActiveLogins.empty()) as ActiveLogins;
    _persistenceRefreshLogic();
    return _activeLogins;
  }

  /// Log out of active user
  Future<void> logout() async {
    // If no user is active, then logout does nothing
    if (_activeLogins.activeUserLogin == null) {
      return;
    }

    // Remove userlogin and set the active user to logged out
    final newUserLogins = _activeLogins.userLogins.removeWhere(
        (ul) => _activeLogins.activeUserLogin == ul.accountMasterKey);
    _activeLogins = _activeLogins.copyWith(
        activeUserLogin: null, userLogins: newUserLogins);

    // Report changed state
    state = AsyncValue.data(_activeLogins);
  }

  /// Log all users
  Future<void> logoutAll() async {
    // If no user is active, then logout does nothing
    if (_activeLogins.activeUserLogin == null) {
      return;
    }

    // Remove all userlogins and set the active user to logged out
    _activeLogins = ActiveLogins.empty();

    // Report changed state
    state = AsyncValue.data(_activeLogins);
  }

  /// Log out specific user identified by its master public key
  Future<void> logoutUser(TypedKey user) async {
    // Remove userlogin and set the active user to logged out
    final newUserLogins = _activeLogins.userLogins
        .removeWhere((ul) => user == ul.accountMasterKey);
    final newActiveUserLogin = _activeLogins.activeUserLogin == user
        ? null
        : _activeLogins.activeUserLogin;
    _activeLogins = ActiveLogins(
        userLogins: newUserLogins, activeUserLogin: newActiveUserLogin);

    // Report changed state
    state = AsyncValue.data(_activeLogins);
  }

  /// Attempt a login and if successful make that user active
  Future<void> login(String publicKey, String password) async {
    state = await AsyncValue.guard<User?>(() async {
      return Future.delayed(
        networkRoundTripTime,
        () => _dummyUser,
      );
    });
  }

  /// Internal method used to listen authentication state changes.
  /// When the auth object is in a loading state, nothing happens.
  /// When the auth object is in a error state, we choose to remove the token
  /// Otherwise, we expect the current auth value to be reflected in our persistence API
  void _persistenceRefreshLogic() {
    ref.listenSelf((_, next) {
      if (next.isLoading) return;
      if (next.hasError) {
        sharedPreferences.remove(_sharedPrefsKey);
        return;
      }

      final val = next.requireValue;
      final isAuthenticated = val == null;

      isAuthenticated
          ? sharedPreferences.remove(_sharedPrefsKey)
          : sharedPreferences.setString(_sharedPrefsKey, val.publicKey);
    });
  }
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(this.message);
}
