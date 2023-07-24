import 'dart:io';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../components/default_app_bar.dart';
import '../providers/local_accounts.dart';
import '../tools/tools.dart';

class NewAccountPage extends ConsumerStatefulWidget {
  const NewAccountPage({super.key});
  static const path = '/new_account';

  @override
  NewAccountPageState createState() {
    return NewAccountPageState();
  }
}

class NewAccountPageState extends ConsumerState<NewAccountPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  late bool isInAsyncCall = false;

  Widget _newAccountForm(BuildContext context,
      {required Future<void> Function(GlobalKey<FormBuilderState>) onSubmit}) {
    return FormBuilder(
      key: _formKey,
      child: ListView(
        children: [
          Text(translate("new_account_page.header"))
              .textStyle(context.headlineSmall)
              .paddingSymmetric(vertical: 16),
          FormBuilderTextField(
            autofocus: true,
            name: 'name',
            decoration: InputDecoration(
                hintText: translate("new_account_page.form_name")),
            maxLength: 64,
            // The validator receives the text that the user has entered.
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
          ),
          FormBuilderTextField(
            name: 'title',
            maxLength: 64,
            decoration: InputDecoration(
                hintText: translate("new_account_page.form_title")),
          ),
          Row(children: [
            const Spacer(),
            Text(translate("new_account_page.instructions"))
                .toCenter()
                .flexible(flex: 6),
            const Spacer(),
          ]).paddingSymmetric(vertical: 4),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                setState(() {
                  isInAsyncCall = true;
                });
                try {
                  await onSubmit(_formKey);
                } finally {
                  setState(() {
                    isInAsyncCall = false;
                  });
                }
              }
            },
            child: Text(translate('new_account_page.create')),
          ).paddingSymmetric(vertical: 4).alignAtCenterRight(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    enableTitleBar(true);
    portraitOnly();

    final localAccounts = ref.watch(localAccountsProvider);

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: DefaultAppBar(context,
          title: Text(translate("new_account_page.titlebar"))),
      body: _newAccountForm(
        context,
        onSubmit: (formKey) async {
          debugPrint(_formKey.currentState?.value.toString());
          FocusScope.of(context).unfocus();
          await Future.delayed(Duration(seconds: 5));
        },
      ).paddingSymmetric(horizontal: 24, vertical: 8),
    ).withModalHUD(context, isInAsyncCall);
  }
}
