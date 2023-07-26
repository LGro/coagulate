import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:quickalert/quickalert.dart';

import '../components/default_app_bar.dart';
import '../entities/proto.dart' as proto;
import '../providers/local_accounts.dart';
import '../providers/logins.dart';
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';

class NewAccountPage extends ConsumerStatefulWidget {
  const NewAccountPage({super.key});
  static const path = '/new_account';

  @override
  NewAccountPageState createState() => NewAccountPageState();
}

class NewAccountPageState extends ConsumerState<NewAccountPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  late bool isInAsyncCall = false;
  static const String formFieldName = 'name';
  static const String formFieldTitle = 'title';

  Future<void> createAccount() async {
    final imws = await newIdentityMaster();
    try {
      final localAccounts = ref.read(localAccountsProvider.notifier);
      final logins = ref.read(loginsProvider.notifier);

      final profile = proto.Profile()
        ..name = _formKey.currentState!.fields[formFieldName]!.value as String
        ..title =
            _formKey.currentState!.fields[formFieldTitle]!.value as String;
      final account = proto.Account()..profile = profile;
      final localAccount = await localAccounts.newAccount(
          identityMaster: imws.identityMaster,
          identitySecret: imws.identitySecret,
          account: account);

      // Log in the new account by default with no pin
      final ok = await logins
          .loginWithNone(localAccount.identityMaster.masterRecordKey);
      assert(ok == true, 'login with none should never fail');
    } on Exception catch (_) {
      await imws.delete();
      rethrow;
    }
  }

  Widget _newAccountForm(BuildContext context,
          {required Future<void> Function(GlobalKey<FormBuilderState>)
              onSubmit}) =>
      FormBuilder(
        key: _formKey,
        child: ListView(
          children: [
            Text(translate('new_account_page.header'))
                .textStyle(context.headlineSmall)
                .paddingSymmetric(vertical: 16),
            FormBuilderTextField(
              autofocus: true,
              name: formFieldName,
              decoration:
                  InputDecoration(hintText: translate('account.form_name')),
              maxLength: 64,
              // The validator receives the text that the user has entered.
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            FormBuilderTextField(
              name: formFieldTitle,
              maxLength: 64,
              decoration:
                  InputDecoration(hintText: translate('account.form_title')),
            ),
            Row(children: [
              const Spacer(),
              Text(translate('new_account_page.instructions'))
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

  @override
  Widget build(BuildContext context) {
    enableTitleBar(true);
    portraitOnly();

//    final localAccountsData = ref.watch(localAccountsProvider);
    final displayModalHUD = isInAsyncCall; // || !localAccountsData.hasValue;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: DefaultAppBar(context,
          title: Text(translate('new_account_page.titlebar'))),
      body: _newAccountForm(
        context,
        onSubmit: (formKey) async {
          debugPrint(_formKey.currentState?.value.toString());
          FocusScope.of(context).unfocus();
          try {
            await createAccount();
          } on Exception catch (e) {
            await QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: translate('new_account_page.error'),
              text: 'Exception: $e',
              //backgroundColor: Colors.black,
              //titleColor: Colors.white,
              //textColor: Colors.white,
            );
          }
        },
      ).paddingSymmetric(horizontal: 24, vertical: 8),
    ).withModalHUD(context, displayModalHUD);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isInAsyncCall', isInAsyncCall));
  }
}
