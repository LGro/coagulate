// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

import '../../../oss_licenses.dart';

Widget _buildLicenseWidget(Package p) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${p.name} ${p.version}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      const SizedBox(height: 10),
      Text(p.license!),
      const SizedBox(height: 20),
    ]);

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  static Route<void> route() => MaterialPageRoute(
      fullscreenDialog: true, builder: (context) => const LicensesPage());

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Open Source Licenses'),
      ),
      body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          ossLicenses.map(_buildLicenseWidget).toList())))));
}
