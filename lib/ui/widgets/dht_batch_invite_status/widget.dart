// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../batch_invite_management/cubit.dart';
import 'cubit.dart';

class DhtBatchInviteStatusWidget extends StatelessWidget {
  const DhtBatchInviteStatusWidget(this.batch, {super.key});

  final Batch batch;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => DhtBatchInviteStatusCubit(batch: batch),
        child:
            BlocBuilder<DhtBatchInviteStatusCubit, DhtBatchInviteStatusState>(
          builder: (context, state) =>
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(state.subkeyNames.entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n')),
          ]),
        ),
      );
}
