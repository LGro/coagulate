// Copyright 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid/veilid.dart';

import 'cubit.dart';

class DhtSharingStatusWidget extends StatelessWidget {
  const DhtSharingStatusWidget({
    required this.recordKeys,
    super.key,
  });

  final Iterable<Typed<FixedEncodedString43>> recordKeys;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => DhtSharingStatusCubit(recordKeys: recordKeys),
        child: BlocBuilder<DhtSharingStatusCubit, DhtSharingStatusState>(
            builder: (context, state) => Text(state.status)),
      );
}
