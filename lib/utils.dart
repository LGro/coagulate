import 'data/models/coag_contact.dart';

/// Find a name to display; mostly required because on iOS the default
/// displayName seems to be empty when only an email address is present
String? displayName(CoagContact contact) {
  if (contact.details?.displayName.isNotEmpty ?? false) {
    return contact.details!.displayName;
  }
  if (contact.systemContact?.displayName.isNotEmpty ?? false) {
    return contact.systemContact!.displayName;
  }
  if (contact.details?.emails.isNotEmpty ?? false) {
    return contact.details!.emails.first.address;
  }
  if (contact.systemContact?.emails.isNotEmpty ?? false) {
    return contact.systemContact!.emails.first.address;
  }
  if (contact.details?.phones.isNotEmpty ?? false) {
    return contact.details!.phones.first.number;
  }
  if (contact.systemContact?.phones.isNotEmpty ?? false) {
    return contact.systemContact!.phones.first.number;
  }
  return null;
}
