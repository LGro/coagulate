import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/user_role.dart';
import '../pages/pages.dart';
import '../state/auth.dart';
import '../state/permissions.dart';

/// This notifier is meant to implement the [Listenable] our [GoRouter] needs.
///
/// We aim to trigger redirects whenever's needed.
/// This is done by calling our (only) listener everytime we want to notify stuff.
/// This allows to centralize global redirecting logic in this class.
/// In this simple case, we just listen to auth changes.
///
/// SIDE NOTE.
/// This might look overcomplicated at a first glance;
/// Instead, this method aims to follow some good some good practices:
///   1. It doesn't require us to pipe down any `ref` parameter
///   2. It works as a complete replacement for [ChangeNotifier] (it's a [Listenable] implementation)
///   3. It allows for listening to multiple providers if needed (we do have a [Ref] now!)
class RouterNotifier extends AutoDisposeAsyncNotifier<void>
    implements Listenable {
  VoidCallback? routerListener;
  bool isAuth = false; // Useful for our global redirect functio

  @override
  Future<void> build() async {
    // One could watch more providers and write logic accordingly

    isAuth = await ref.watch(
      authNotifierProvider.selectAsync((data) => data != null),
    );

    ref.listenSelf((_, __) {
      // One could write more conditional logic for when to call redirection
      if (state.isLoading) return;
      routerListener?.call();
    });
  }

  /// Redirects the user when our authentication changes
  String? redirect(BuildContext context, GoRouterState state) {
    if (this.state.isLoading || this.state.hasError) return null;

    final isSplash = state.location == IndexPage.path;

    if (isSplash) {
      return isAuth ? HomePage.path : LoginPage.path;
    }

    final isLoggingIn = state.location == LoginPage.path;
    if (isLoggingIn) return isAuth ? HomePage.path : null;

    return isAuth ? null : IndexPage.path;
  }

  /// Our application routes. Obtained through code generation
  List<GoRoute> get routes => [
        GoRoute(
          path: IndexPage.path,
          builder: (context, state) => const IndexPage(),
        ),
        GoRoute(
            path: HomePage.path,
            builder: (context, state) => const HomePage(),
            redirect: (context, state) async {
              if (state.location == HomePage.path) return null;

              final roleListener = ProviderScope.containerOf(context).listen(
                permissionsProvider.select((value) => value.valueOrNull),
                (previous, next) {},
              );

              final userRole = roleListener.read();
              final redirectTo = userRole?.redirectBasedOn(state.location);

              roleListener.close();
              return redirectTo;
            },
            routes: [
              GoRoute(
                path: AdminPage.path,
                builder: (context, state) => const AdminPage(),
              ),
              GoRoute(
                path: UserPage.path,
                builder: (context, state) => const UserPage(),
              ),
              GoRoute(
                path: GuestPage.path,
                builder: (context, state) => const GuestPage(),
              )
            ]),
        GoRoute(
          path: LoginPage.path,
          builder: (context, state) => const LoginPage(),
        ),
      ];

  /// Adds [GoRouter]'s listener as specified by its [Listenable].
  /// [GoRouteInformationProvider] uses this method on creation to handle its
  /// internal [ChangeNotifier].
  /// Check out the internal implementation of [GoRouter] and
  /// [GoRouteInformationProvider] to see this in action.
  @override
  void addListener(VoidCallback listener) {
    routerListener = listener;
  }

  /// Removes [GoRouter]'s listener as specified by its [Listenable].
  /// [GoRouteInformationProvider] uses this method when disposing,
  /// so that it removes its callback when destroyed.
  /// Check out the internal implementation of [GoRouter] and
  /// [GoRouteInformationProvider] to see this in action.
  @override
  void removeListener(VoidCallback listener) {
    routerListener = null;
  }
}

final routerNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RouterNotifier, void>(() {
  return RouterNotifier();
});

/// A simple extension to determine wherever should we redirect our users
extension RedirecttionBasedOnRole on UserRole {
  /// Redirects the users based on [this] and its current [location]
  String? redirectBasedOn(String location) {
    switch (this) {
      case UserRole.admin:
        return null;
      case UserRole.verifiedUser:
      case UserRole.unverifiedUser:
        if (location == AdminPage.path) return HomePage.path;
        return null;
      case UserRole.guest:
      case UserRole.none:
        if (location != HomePage.path) return HomePage.path;
        return null;
    }
  }
}
