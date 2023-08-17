import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../components/default_app_bar.dart';
import '../components/signal_strength_meter.dart';
import '../entities/preferences.dart';
import '../providers/local_accounts.dart';
import '../providers/logins.dart';
import '../providers/window_control.dart';
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  late bool isInAsyncCall = false;
  ThemeService? themeService;
  ThemePreferences? themePreferences;
  static const String formFieldTheme = 'theme';
  // static const String formFieldTitle = 'title';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(windowControlProvider.notifier).changeWindowSetup(
          TitleBarStyle.normal, OrientationCapability.normal);
      final tsinst = await ThemeService.instance;
      setState(() {
        themeService = tsinst;
        themePreferences = tsinst.load();
      });
    });
  }

  List<DropdownMenuItem<dynamic>> _getThemeDropdownItems() {
    const colorPrefs = ColorPreference.values;
    final colorNames = {
      ColorPreference.scarlet: translate('themes.scarlet'),
      ColorPreference.vapor: translate('themes.vapor'),
      ColorPreference.babydoll: translate('themes.babydoll'),
      ColorPreference.gold: translate('themes.gold'),
      ColorPreference.garden: translate('themes.garden'),
      ColorPreference.forest: translate('themes.forest'),
      ColorPreference.arctic: translate('themes.arctic'),
      ColorPreference.lapis: translate('themes.lapis'),
      ColorPreference.eggplant: translate('themes.eggplant'),
      ColorPreference.lime: translate('themes.lime'),
      ColorPreference.grim: translate('themes.grim'),
      ColorPreference.contrast: translate('themes.contrast')
    };

    return colorPrefs
        .map((e) => DropdownMenuItem(value: e, child: Text(colorNames[e]!)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(windowControlProvider);
    final themeService = ref.watch(themeServiceProvider).asData();

    return ThemeSwitchingArea(
        child: Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: DefaultAppBar(
          title: Text(translate('settings_page.titlebar')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop<void>(),
          ),
          actions: const <Widget>[
            SignalStrengthMeterWidget(),
          ]),

      body: FormBuilder(
        key: _formKey,
        child: ListView(
          children: [
            ThemeSwitcher.withTheme(
                builder: (_, switcher, theme) => FormBuilderDropdown(
                    name: formFieldTheme,
                    decoration: InputDecoration(
                        label: Text(translate('settings_page.color_theme'))),
                    items: _getThemeDropdownItems(),
                    initialValue: themePreferences?.colorPreference,
                    onChanged: (value) async {
                      final tprefs = themePreferences;
                      if (tprefs != null) {
                        final newPrefs = tprefs.copyWith(
                            colorPreference: value as ColorPreference);
                        final tservice = themeService;
                        if (tservice != null) {
                          await tservice.save(newPrefs);
                          switcher.changeTheme(theme: tservice.get(newPrefs));
                        }
                        setState(() {
                          themePreferences = newPrefs;
                        });
                      }
                    }))

            // Text(translate('settings_page.header'))
            //     .textStyle(context.headlineSmall)
            //     .paddingSymmetric(vertical: 16),
            // FormBuilderTextField(
            //   autofocus: true,
            //   name: formFieldName,
            //   decoration:
            //       InputDecoration(hintText: translate('account.form_name')),
            //   maxLength: 64,
            //   // The validator receives the text that the user has entered.
            //   validator: FormBuilderValidators.compose([
            //     FormBuilderValidators.required(),
            //   ]),
            // ),
            // FormBuilderTextField(
            //   name: formFieldTitle,
            //   maxLength: 64,
            //   decoration:
            //       InputDecoration(hintText: translate('account.form_title')),
            // ),
            // Row(children: [
            //   const Spacer(),
            //   Text(translate('new_account_page.instructions'))
            //       .toCenter()
            //       .flexible(flex: 6),
            //   const Spacer(),
            // ]).paddingSymmetric(vertical: 4),
            // ElevatedButton(
            //   onPressed: () async {
            //     if (_formKey.currentState?.saveAndValidate() ?? false) {
            //       setState(() {
            //         isInAsyncCall = true;
            //       });
            //       try {
            //         await onSubmit(_formKey);
            //       } finally {
            //         if (mounted) {
            //           setState(() {
            //             isInAsyncCall = false;
            //           });
            //         }
            //       }
            //     }
            //   },
            //   child: Text(translate('new_account_page.create')),
            // ).paddingSymmetric(vertical: 4).alignAtCenterRight(),
          ],
        ),
      ).paddingSymmetric(horizontal: 24, vertical: 8),
    ));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isInAsyncCall', isInAsyncCall));
  }
}
