import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../components/default_app_bar.dart';
import '../tools/desktop_control.dart';

class NewAccountForm extends ConsumerStatefulWidget {
  const NewAccountForm({super.key});

  @override
  NewAccountFormState createState() {
    return NewAccountFormState();
  }
}

class NewAccountFormState extends ConsumerState<NewAccountForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            key: const ValueKey("name"),
            autofocus: true,
            decoration:
                InputDecoration(hintText: translate("new_account_form.name")),
            maxLength: 64,
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          TextFormField(
            key: const ValueKey("title"),
            maxLength: 64,
            decoration:
                InputDecoration(hintText: translate("new_account_form.title")),
          ),
          Row(children: [
            const Spacer(),
            Text(translate("new_account_form.instructions"))
                .toCenter()
                .flexible(flex: 4),
            const Spacer(),
          ]).paddingSymmetric(vertical: 24),
          ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
              }
            },
            child: Text(translate('new_account_form.create')),
          ).paddingSymmetric(vertical: 16).toCenter(),
        ],
      ),
    );
  }
}
