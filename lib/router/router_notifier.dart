import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../pages/pages.dart';
import '../providers/local_accounts.dart';

part 'router_notifier.g.dart';

@riverpod
class RouterNotifier extends _$RouterNotifier implements Listenable {
  /// GoRouter listener
  VoidCallback? routerListener;

  /// Do we need to make or import an account immediately?
  bool hasAnyAccount = false;

  /// AsyncNotifier build
  @override
  Future<void> build() async {
    hasAnyAccount = await ref.watch(
      localAccountsProvider.selectAsync((data) => data.isNotEmpty),
    );

    // When this notifier's state changes, inform GoRouter
    ref.listenSelf((_, __) {
      if (state.isLoading) {
        return;
      }
      routerListener?.call();
    });
  }

  /// Redirects when our state changes
  String? redirect(BuildContext context, GoRouterState state) {
    if (this.state.isLoading || this.state.hasError) {
      return null;
    }

    // No matter where we are, if there's not

    switch (state.location) {
      case IndexPage.path:
        return hasAnyAccount ? HomePage.path : NewAccountPage.path;
      case NewAccountPage.path:
        return hasAnyAccount ? HomePage.path : null;
      default:
        return hasAnyAccount ? null : NewAccountPage.path;
    }
  }

  /// Our application routes
  List<GoRoute> get routes => [
        GoRoute(
          path: IndexPage.path,
          builder: (context, state) => const IndexPage(),
        ),
        GoRoute(
          path: HomePage.path,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: NewAccountPage.path,
          builder: (context, state) => const NewAccountPage(),
        ),
      ];

  ///////////////////////////////////////////////////////////////////////////
  /// Listenable

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
