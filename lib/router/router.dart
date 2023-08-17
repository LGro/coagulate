import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../pages/index.dart';
import 'router_notifier.dart';

part 'router.g.dart';

final _key = GlobalKey<NavigatorState>(debugLabel: 'routerKey');

/// This simple provider caches our GoRouter.
@riverpod
GoRouter router(RouterRef ref) {
  final notifier = ref.watch(routerNotifierProvider.notifier);
  return GoRouter(
    navigatorKey: _key,
    refreshListenable: notifier,
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: notifier.routes,
    redirect: notifier.redirect,
  );
}
