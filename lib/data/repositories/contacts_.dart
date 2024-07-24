// // Copyright 2024 The Coagulate Authors. All rights reserved.
// // SPDX-License-Identifier: MPL-2.0

// import 'dart:async';
// import 'dart:convert';

// import 'package:collection/collection.dart';
// import 'package:fast_immutable_collections/fast_immutable_collections.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';
// import 'package:rxdart/subjects.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
// import 'package:veilid/veilid.dart';

// import '../../veilid_processor/repository/processor_repository.dart';
// import '../models/coag_contact.dart';
// import '../models/contact_location.dart';
// import '../models/contact_update.dart';
// import '../models/profile_sharing_settings.dart';
// import '../providers/distributed_storage/base.dart';
// import '../providers/persistent_storage/base.dart';
// import '../providers/system_contacts/base.dart';
// import '../providers/system_contacts/system_contacts.dart';

// /// Entrypoint for application layer when it comes to [CoagContact]
// class ContactsRepository {
//   ContactsRepository(this.persistentStorage, this.distributedStorage,
//       this.systemContactsStorage) {
//     unawaited(_init());

//     // Regularly check for updates from the persistent storage,
//     // e.g. in case it was updated from background processes.
//     timerPersistentStorageRefresh =
//         Timer.periodic(Duration(seconds: 5), (_) async => ()
//             // _updateFromPersistentStorage()
//             );

//     // TODO: Check if we can/should replace this with listening to the Veilid update stream
//     timerDhtRefresh = Timer.periodic(
//         Duration(seconds: 5), (_) async => updateAndWatchReceivingDHT());
//   }

//   late final Timer? timerPersistentStorageRefresh;
//   late final Timer? timerDhtRefresh;
//   String? profileContactId;

//   Future<void> updateCircleMemberships(
//       Map<String, List<String>> memberships) async {
//     _circleMemberships = memberships;
//     _circlesStreamController.add(null);
//     await persistentStorage.updateCircleMemberships(memberships);

//     for (final contact in _contacts.values) {
//       final profileContact = getProfileContact();
//       if (contact.dhtSettingsForSharing == null || profileContact == null) {
//         continue;
//       }

//       final sharedProfile = json.encode(removeNullOrEmptyValues(
//           filterAccordingToSharingProfile(
//                   profile: profileContact,
//                   settings: _profileSharingSettings,
//                   activeCircles:
//                       _circleMemberships[contact.coagContactId] ?? [],
//                   shareBackSettings: contact.dhtSettingsForReceiving)
//               .toJson()));
//       if (sharedProfile == contact.sharedProfile) {
//         continue;
//       }

//       // TODO: This seems too big of an action to trigger
//       // disentangle this to just updating the contact and letting the ui know
//       // push changes to dht async
//       await updateContact(contact.copyWith(sharedProfile: sharedProfile));
//     }
//   }

//   // TODO: Refactor redundancies with updateAndWatchReceivingDHT
//   Future<void> _veilidUpdateValueChangeCallback(
//       VeilidUpdateValueChange update) async {
//     final contact = _contacts.values.firstWhereOrNull(
//         (c) => c.dhtSettingsForReceiving!.key == update.key.toString());

//     // FIXME: Appropriate error handling
//     if (contact == null) {
//       return;
//     }

//     final updatedContact =
//         await distributedStorage.updateContactReceivingDHT(contact);
//     if (updatedContact != contact) {
//       // TODO: Use update time from when the update was sent not received
//       // TODO: Can it happen that details are null?
//       // TODO: When temporary locations are updated, only record an update about added / updated locations / check-ins
//       await _saveUpdate(ContactUpdate(
//           coagContactId: contact.coagContactId,
//           oldContact: contact.details!,
//           newContact: updatedContact.details!,
//           timestamp: DateTime.now()));
//       await updateContact(updatedContact);
//     }
//   }

//   Future<void> _updateFromPersistentStorage() async {
//     await (await SharedPreferences.getInstance()).reload();
//     final storedContacts = await persistentStorage.getAllContacts();
//     // TODO: Working with _contacts.values directly is prone to a ConcurrentModificationError; copying as a workaround
//     for (final contact in List<CoagContact>.from(_contacts.values)) {
//       // Update if there is no matching contact but is a corresponding ID
//       if (!storedContacts.containsValue(contact) &&
//           storedContacts.containsKey(contact.coagContactId)) {
//         // TODO: Check most recent update timestamp and make sure the on from persistent storag is more recent
//         await saveContact(storedContacts[contact.coagContactId]!);
//       }
//     }
//   }

//   // TODO: Does that need to be separate depending on whether the update originated from the dht or not?
//   //       Or maybe separate depending on what part is updated (details, locations, dht stuff)
//   Future<void> updateContact(CoagContact contact) async {
//     final oldContact = _contacts[contact.coagContactId];
//     // Skip in case already up to date
//     if (oldContact == contact) {
//       return;
//     }

//     // Early save to not keep everyone waiting for the DHT update
//     await saveContact(contact);

//     // TODO: Allow creation of a new system contact via update contact as well; might require custom contact details schema
//     // Update system contact if linked and contact details changed
//     if (contact.systemContact != null &&
//         _contacts[contact.coagContactId]?.systemContact !=
//             contact.systemContact) {
//       // TODO: How to reconsile system contacts if permission was removed intermittently and is then granted again?
//       try {
//         await systemContactsStorage.updateContact(contact.systemContact!);
//       } on MissingSystemContactsPermissionError {
//         _systemContactAccessGrantedStreamController.add(false);
//       }
//     }

//     if (contact.sharedProfile != null) {
//       contact = await distributedStorage.updateContactSharingDHT(contact);
//     }

//     if (contact.dhtSettingsForReceiving != null) {
//       contact = await distributedStorage.updateContactReceivingDHT(contact);
//     }

//     // Final save after a potential dht update
//     await saveContact(contact);
//   }
// }
