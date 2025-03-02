// // Copyright 2024 The Coagulate Authors. All rights reserved.
// // SPDX-License-Identifier: MPL-2.0

// import 'package:coagulate/data/models/coag_contact.dart';
// import 'package:coagulate/data/repositories/contacts.dart';
// import 'package:coagulate/ui/contact_details/page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';
// import 'package:flutter_test/flutter_test.dart';

// import '../mocked_providers.dart';

// Future<Widget> createContactPage(
//         ContactsRepository contactsRepository, String coagContactId) async =>
//     RepositoryProvider.value(
//         value: contactsRepository,
//         child: MaterialApp(
//             home: Directionality(
//           textDirection: TextDirection.ltr,
//           child: ContactPage(coagContactId: coagContactId),
//         )));

// ContactsRepository _contactsRepositoryFromContact(CoagContact contact) =>
//     ContactsRepository(
//         DummyPersistentStorage(
//             [contact].asMap().map((_, v) => MapEntry(v.coagContactId, v))),
//         DummyDistributedStorage(),
//         DummySystemContacts([
//           Contact(emails: [Email('test@mail.com')])
//         ]));

void main() {
//   group('Contact Details Page Widget Tests', () {
//     // TODO: Replace with unit test of the details merging functionality when it arrives
//     testWidgets('Testing Details Displayed', (tester) async {
//       final contact = CoagContact(
//           coagContactId: '1',
//           systemContact: Contact(emails: [Email('test@mail.com')]),
//           details: ContactDetails(
//               displayName: 'Test Name',
//               name: Name(first: 'Test', last: 'Name'),
//               phones: [Phone('12345')]));
//       final contactsRepository = _contactsRepositoryFromContact(contact);

//       final contactPage =
//           await createContactPage(contactsRepository, contact.coagContactId);
//       await tester.pumpWidget(contactPage);

//       expect(find.text(contact.details!.displayName), findsOneWidget);
//       expect(find.text(contact.details!.phones[0].number), findsOneWidget);
//       expect(
//           find.text(contact.systemContact!.emails[0].address), findsOneWidget);
//     });
//     testWidgets('Circles update causes details page update', (tester) async {
//       final contact = CoagContact(
//           coagContactId: '1',
//           details: ContactDetails(
//               displayName: 'Test Name',
//               name: Name(first: 'Test', last: 'Name')));
//       final contactsRepository = _contactsRepositoryFromContact(contact);
//       await contactsRepository.addCircle('c1', 'circle1');
//       // Add our contact with id 1 to circle c1
//       await contactsRepository.updateCircleMemberships({
//         '1': ['c1']
//       });

//       final contactPage =
//           await createContactPage(contactsRepository, contact.coagContactId);
//       await tester.pumpWidget(contactPage);

//       await contactsRepository.updateCirclesForContact('1', ['c1']);
//       await tester.pump();

//       expect(find.text('circle1'), findsOneWidget);
//       expect(find.text('Add them to circles'), findsNothing);
//     });
//   });
}
