// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ui/batch_invite_management/page.dart';
import '../veilid_init.dart';

class CoagulateBatchManagementApp extends StatelessWidget {
  const CoagulateBatchManagementApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Coagulate Batch Invite Management',
      home: FutureProvider<CoagulateGlobalInit?>(
          initialData: null,
          create: (context) async => CoagulateGlobalInit.initialize(),
          // CoagulateGlobalInit.initialize can throw Already attached VeilidAPIException which is fine
          catchError: (context, error) => null,
          builder: (context, child) =>
              (context.watch<CoagulateGlobalInit?>() == null)
                  ? const Center(child: CircularProgressIndicator())
                  : const BatchInvitesPage()));
}
