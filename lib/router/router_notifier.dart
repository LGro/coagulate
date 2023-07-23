import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/pages.dart';
import '../providers/logins.dart';

class RouterNotifier extends AutoDisposeAsyncNotifier<void>
    implements Listenable {
  /// GoRouter listener
  VoidCallback? routerListener;

  /// Router state for redirect
  bool hasActiveUserLogin = false;

  /// AsyncNotifier build
  @override
  Future<void> build() async {
    hasActiveUserLogin = await ref.watch(
      loginsProvider.selectAsync((data) => data.activeUserLogin != null),
    );

    // When this notifier's state changes, inform GoRouter
    ref.listenSelf((_, __) {
      if (state.isLoading) return;
      routerListener?.call();
    });
  }

  /// Redirects when our state changes
  String? redirect(BuildContext context, GoRouterState state) {
    if (this.state.isLoading || this.state.hasError) return null;

    switch (state.location) {
      case IndexPage.path:
        return hasActiveUserLogin ? HomePage.path : LoginPage.path;
      case LoginPage.path:
        return hasActiveUserLogin ? HomePage.path : null;
      default:
        return hasActiveUserLogin ? null : LoginPage.path;
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
          // redirect: (context, state) async {
          //   if (state.location == HomePage.path) return null;

          //   // final roleListener = ProviderScope.containerOf(context).listen(
          //   //   permissionsProvider.select((value) => value.valueOrNull),
          //   //   (previous, next) {},
          //   // );

          //   // final userRole = roleListener.read();
          //   // final redirectTo = userRole?.redirectBasedOn(state.location);

          //   // roleListener.close();
          //   // return redirectTo;
          // },
          // routes: [
          //   GoRoute(
          //     path: AdminPage.path,
          //     builder: (context, state) => const AdminPage(),
          //   ),
          //   GoRoute(
          //     path: UserPage.path,
          //     builder: (context, state) => const UserPage(),
          //   ),
          //   GoRoute(
          //     path: GuestPage.path,
          //     builder: (context, state) => const GuestPage(),
          //   )
          // ]
        ),
        GoRoute(
          path: LoginPage.path,
          builder: (context, state) => const LoginPage(),
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

final routerNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RouterNotifier, void>(() {
  return RouterNotifier();
});

/// A simple extension to determine wherever should we redirect our users
// extension RedirecttionBasedOnRole on UserRole {
//   /// Redirects the users based on [this] and its current [location]
//   String? redirectBasedOn(String location) {
//     switch (this) {
//       case UserRole.admin:
//         return null;
//       case UserRole.verifiedUser:
//       case UserRole.unverifiedUser:
//         if (location == AdminPage.path) return HomePage.path;
//         return null;
//       case UserRole.guest:
//       case UserRole.none:
//         if (location != HomePage.path) return HomePage.path;
//         return null;
//     }
//   }
// }
