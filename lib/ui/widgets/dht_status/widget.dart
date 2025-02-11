// Copyright 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/coag_contact.dart';
import 'cubit.dart';

class DhtStatusWidget extends StatelessWidget {
  const DhtStatusWidget({
    required this.statusWidgets,
    required this.dhtSettings,
    super.key,
  });

  final Map<String, Widget> statusWidgets;
  final ContactDHTSettings dhtSettings;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => DhtStatusCubit(dhtSettings: dhtSettings),
        child: BlocBuilder<DhtStatusCubit, DhtStatusState>(
            builder: (context, state) =>
                // TODO: Replace default with const SizedBox.shrink()
                statusWidgets[state.status] ?? Text(state.status)),
      );
}
