/* Adapted from BSD-3-Clause licensed
https://github.com/juliansteenbakker/mobile_scanner/blob/master/example/lib/barcode_scanner_pageview.dart

BSD 3-Clause License

Copyright (c) 2022, Julian Steenbakker
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


For the changes (mainly in onDetect): Copyright 2024 Lukas Grossberger
*/
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../cubit/contacts_cubit.dart';
import '../../data/repositories/contacts.dart';

class BarcodeScannerPageView extends StatefulWidget {
  const BarcodeScannerPageView({super.key});

  @override
  State<BarcodeScannerPageView> createState() => _BarcodeScannerPageViewState();
}

class _BarcodeScannerPageViewState extends State<BarcodeScannerPageView> {
  final MobileScannerController controller = MobileScannerController();

  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    unawaited(controller.start());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('QR Code Scanner')),
        backgroundColor: Colors.black,
        body: PageView(
          controller: pageController,
          onPageChanged: (index) async {
            // Stop the camera view for the current page,
            // and then restart the camera for the new page.
            await controller.stop();

            // When switching pages, add a delay to the next start call.
            // Otherwise the camera will start before the next page is displayed
            await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

            if (!mounted) {
              return;
            }

            unawaited(controller.start());
          },
          children: [_BarcodeScannerPage(controller: controller)],
        ),
      );

  @override
  Future<void> dispose() async {
    pageController.dispose();
    super.dispose();
    controller.dispose();
  }
}

class _BarcodeScannerPage extends StatelessWidget {
  const _BarcodeScannerPage({required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (context) => CoagContactCubit(context.read<ContactsRepository>()),
      child: BlocConsumer<CoagContactCubit, CoagContactState>(
        listener: (context, state) => {},
        builder: (context, state) => MobileScanner(
            controller: controller,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null &&
                    (barcode.rawValue!.startsWith('https://coagulate.social') ||
                        barcode.rawValue!.startsWith('coag://') ||
                        barcode.rawValue!.startsWith('coagulate://'))) {
                  unawaited(context
                      .read<CoagContactCubit>()
                      .handleCoagulationURI(barcode.rawValue!));
                  // TODO(LGro): Instead of closing everything, display waiting spinner until successful or failed dht fetch and details
                  controller.dispose();
                  Navigator.of(context).pop();
                  return;
                }
              }
            }),
      ));
}
