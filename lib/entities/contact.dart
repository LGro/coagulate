
class Contact {
  String name;
  String publicKey;
  bool available;

  Contact(this.name, this.publicKey) : available = false;

  Contact.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        publicKey = json['public_key'],
        available = json['available'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'public_key': publicKey,
      'available': available,
    };
  }
}

// // Synchronize the app state contact list with the internal one
// void sortAndStoreAppStateContactList(List<dynamic> ffasContactList) {
//   ffasContactList.sortBy((element) => element["name"] as String);
//   FFAppState().update(() {
//     FFAppState().ContactList = ffasContactList;
//   });
// }

// // Called when a new contact is added or an existing one is edited
// Future<String> vcsUpdateContact(
//   String id,
//   String name,
//   String publicKey,
// ) async {
//   var api = Veilid.instance;
//   try {
//     // if we are adding a new contact, make its id
//     var newContact = false;
//     if (id.isEmpty) {
//       id = const Uuid().v4();
//       newContact = true;
//     }

//     // Trim name
//     name = name.trim();

//     // Validate name and public key
//     if (name.length > 127) {
//       return "Name is too long.";
//     }
//     if (name.isEmpty) {
//       return "Name can not be empty";
//     }
//     if (!isValidDHTKey(publicKey)) {
//       return "Public key is not valid";
//     }

//     // update entry in internal contacts table
//     var contactsDb = await api.openTableDB("contacts", 1);
//     var contact = Contact(name, publicKey);
//     await contactsDb.storeStringJson(0, id, contact);

//     // update app state
//     var contactJson = contact.toJson();
//     contactJson['id'] = id;

//     var ffasContactList = FFAppState().ContactList;
//     if (newContact) {
//       // Add new contact
//       ffasContactList.add(contactJson);
//     } else {
//       // Update existing contact
//       ffasContactList.forEachIndexedWhile((i, e) {
//         if (e['id'] == id) {
//           ffasContactList[i] = contactJson;
//           return false;
//         }
//         return true;
//       });
//     }

//     // Sort the contact list
//     sortAndStoreAppStateContactList(ffasContactList);
//   } catch (e) {
//     return e.toString();
//   }

//   return "";
// }

// // Called when a contact is to be removed
// Future<void> vcsDeleteContact(String id) async {
//   //
// }