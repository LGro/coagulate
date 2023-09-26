// ignore_for_file: prefer_const_constructors

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../components/contact_invitation_list_widget.dart';
import '../../components/contact_list_widget.dart';
import '../../entities/local_account.dart';
import '../../proto/proto.dart' as proto;
import '../../providers/contact.dart';
import '../../providers/contact_invite.dart';
import '../../tools/theme_service.dart';
import '../../tools/tools.dart';
import '../../veilid_support/veilid_support.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({
    required this.localAccounts,
    required this.activeUserLogin,
    required this.account,
    super.key,
  });

  final IList<LocalAccount> localAccounts;
  final TypedKey activeUserLogin;
  final proto.Account account;

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends ConsumerState<AccountPage> {
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    final contactInvitationRecordList =
        ref.watch(fetchContactInvitationRecordsProvider).asData?.value ??
            const IListConst([]);
    final contactList = ref.watch(fetchContactListProvider).asData?.value ??
        const IListConst([]);

    return SizedBox(
        child: Column(children: <Widget>[
      if (contactInvitationRecordList.isNotEmpty)
        ExpansionTile(
          tilePadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          backgroundColor: scale.primaryScale.border,
          collapsedBackgroundColor: scale.primaryScale.border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            translate('account_page.contact_invitations'),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium!
                .copyWith(color: scale.primaryScale.subtleText),
          ),
          initiallyExpanded: true,
          children: [
            ContactInvitationListWidget(
                contactInvitationRecordList: contactInvitationRecordList)
          ],
        ).paddingLTRB(8, 0, 8, 8),
      ContactListWidget(contactList: contactList).expanded(),
    ]));
  }
}
