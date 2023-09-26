import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../pages/chat_only_page.dart';
import '../pages/home.dart';
import '../pages/index.dart';
import '../pages/new_account.dart';
import '../pages/settings.dart';
import '../providers/chat.dart';
import '../providers/local_accounts.dart';
import '../tools/responsive.dart';
import '../veilid_init.dart';

part 'router_notifier.g.dart';

@riverpod
class RouterNotifier extends _$RouterNotifier implements Listenable {
  /// GoRouter listener
  VoidCallback? routerListener;

  /// Do we need to make or import an account immediately?
  bool hasAnyAccount = false;
  bool hasActiveChat = false;

  /// AsyncNotifier build
  @override
  Future<void> build() async {
    hasAnyAccount = await ref.watch(
      localAccountsProvider.selectAsync((data) => data.isNotEmpty),
    );
    hasActiveChat = ref.watch(activeChatStateProvider).asData?.value != null;

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
    switch (state.matchedLocation) {
      case '/':

        // Wait for veilid to be initialized
        if (!eventualVeilid.isCompleted) {
          return null;
        }

        return hasAnyAccount ? '/home' : '/new_account';
      case '/new_account':
        return hasAnyAccount ? '/home' : null;
      case '/home':
        if (!hasAnyAccount) {
          return '/new_account';
        }
        if (responsiveVisibility(
            context: context,
            tablet: false,
            tabletLandscape: false,
            desktop: false)) {
          if (hasActiveChat) {
            return '/home/chat';
          }
        }
        return null;
      case '/home/chat':
        if (!hasAnyAccount) {
          return '/new_account';
        }
        if (responsiveVisibility(
            context: context,
            tablet: false,
            tabletLandscape: false,
            desktop: false)) {
          if (!hasActiveChat) {
            return '/home';
          }
        } else {
          return '/home';
        }
        return null;
      case '/home/settings':
      case '/new_account/settings':
        return null;
      default:
        return hasAnyAccount ? null : '/new_account';
    }
  }

  /// Our application routes
  List<GoRoute> get routes => [
        GoRoute(
          path: '/',
          builder: (context, state) => const IndexPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
            GoRoute(
              path: 'chat',
              builder: (context, state) => const ChatOnlyPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/new_account',
          builder: (context, state) => const NewAccountPage(),
          routes: [
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
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
