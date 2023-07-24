import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../components/default_app_bar.dart';
import '../components/new_account_form.dart';
import '../tools/tools.dart';

class NewAccountPage extends ConsumerWidget {
  const NewAccountPage({super.key});
  static const path = '/new_account';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    enableTitleBar(true);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: DefaultAppBar(context,
            title: Text(translate("new_account_page.title"))),
        body: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(translate("new_account_page.header"))
                  .textStyle(context.headlineSmall)
                  .paddingSymmetric(vertical: 16),
              const NewAccountForm().flexible(),
              Text(translate("new_account_page.import"))
            ],
          ),
        ));
  }
}
