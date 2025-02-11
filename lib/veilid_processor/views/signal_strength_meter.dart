import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/quickalert.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';
import 'package:veilid_support/veilid_support.dart';

import '../cubit/connection_state_cubit.dart';
import '../repository/processor_repository.dart';

class SignalStrengthMeterWidget extends StatelessWidget {
  const SignalStrengthMeterWidget({super.key});

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    const iconSize = 16.0;

    return const Text('Signal');

    // return MultiBlocProvider(
    //     providers: [
    //       BlocProvider<ConnectionStateCubit>(
    //           create: (context) =>
    //               ConnectionStateCubit(ProcessorRepository.instance)),
    //     ],
    //     child: BlocBuilder<ConnectionStateCubit, ProcessorConnectionState>(
    //         builder: (context, state) {
    //       late final Widget iconWidget;
    //       state.when(
    //           data: (connectionState) {
    //             late final double value;
    //             switch (connectionState.attachment.state) {
    //               case AttachmentState.detached:
    //                 iconWidget = const Icon(Icons.signal_cellular_nodata,
    //                     size: iconSize);
    //                 return;
    //               case AttachmentState.detaching:
    //                 iconWidget =
    //                     const Icon(Icons.signal_cellular_off, size: iconSize);
    //                 return;
    //               case AttachmentState.attaching:
    //                 value = 0;
    //               case AttachmentState.attachedWeak:
    //                 value = 1;
    //               case AttachmentState.attachedStrong:
    //                 value = 2;
    //               case AttachmentState.attachedGood:
    //                 value = 3;
    //               case AttachmentState.fullyAttached:
    //                 value = 4;
    //               case AttachmentState.overAttached:
    //                 value = 4;
    //             }

    //             iconWidget = SignalStrengthIndicator.bars(
    //                 value: value, size: iconSize, barCount: 4, spacing: 2);
    //           },
    //           loading: () => {iconWidget = const Icon(Icons.warning)},
    //           error: (e, st) => {
    //                 iconWidget = IconButton(
    //                     onPressed: () async => QuickAlert.show(
    //                         type: QuickAlertType.error,
    //                         context: context,
    //                         title: 'Error',
    //                         text: 'Error: {e}\n StackTrace: {st}'),
    //                     icon: const Icon(Icons.error))
    //               });
    //       return iconWidget;
    //     }));
  }
}
