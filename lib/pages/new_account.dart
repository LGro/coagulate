import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../components/default_app_bar.dart';
import '../components/signal_strength_meter.dart';
import '../entities/entities.dart';
import '../providers/local_accounts.dart';
import '../providers/logins.dart';
import '../providers/window_control.dart';
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';

class NewAccountPage extends ConsumerStatefulWidget {
  const NewAccountPage({super.key});

  @override
  NewAccountPageState createState() => NewAccountPageState();
}

class NewAccountPageState extends ConsumerState<NewAccountPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  late bool isInAsyncCall = false;
  static const String formFieldName = 'name';
  static const String formFieldPronouns = 'pronouns';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
      await ref.read(windowControlProvider.notifier).changeWindowSetup(
          TitleBarStyle.normal, OrientationCapability.portraitOnly);
    });
  }

  /// Creates a new master identity, an account associated with the master
  /// identity, stores the account in the identity key and then logs into
  /// that account with no password set at this time
  Future<void> createAccount() async {
    final localAccounts = ref.read(localAccountsProvider.notifier);
    final logins = ref.read(loginsProvider.notifier);

    final name = _formKey.currentState!.fields[formFieldName]!.value as String;
    final pronouns =
        _formKey.currentState!.fields[formFieldPronouns]!.value as String? ??
            '';

    final imws = await IdentityMasterWithSecrets.create();
    try {
      final localAccount = await localAccounts.newLocalAccount(
          identityMaster: imws.identityMaster,
          identitySecret: imws.identitySecret,
          name: name,
          pronouns: pronouns);

      // Log in the new account by default with no pin
      final ok = await logins.login(localAccount.identityMaster.masterRecordKey,
          EncryptionKeyType.none, '');
      assert(ok, 'login with none should never fail');
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
                  InputDecoration(labelText: translate('account.form_name')),
              maxLength: 64,
              // The validator receives the text that the user has entered.
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            FormBuilderTextField(
              name: formFieldPronouns,
              maxLength: 64,
              decoration: InputDecoration(
                  labelText: translate('account.form_pronouns')),
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
                    if (mounted) {
                      setState(() {
                        isInAsyncCall = false;
                      });
                    }
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
    ref.watch(windowControlProvider);

    final localAccounts = ref.watch(localAccountsProvider);
    final logins = ref.watch(loginsProvider);

    final displayModalHUD =
        isInAsyncCall || !localAccounts.hasValue || !logins.hasValue;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: DefaultAppBar(
          title: Text(translate('new_account_page.titlebar')),
          actions: [
            const SignalStrengthMeterWidget(),
            IconButton(
                icon: const Icon(Icons.settings),
                tooltip: translate('app_bar.settings_tooltip'),
                onPressed: () async {
                  context.go('/new_account/settings');
                })
          ]),
      body: _newAccountForm(
        context,
        onSubmit: (formKey) async {
          FocusScope.of(context).unfocus();
          try {
            await createAccount();
          } on Exception catch (e) {
            if (context.mounted) {
              await showErrorModal(context, translate('new_account_page.error'),
                  'Exception: $e');
            }
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
