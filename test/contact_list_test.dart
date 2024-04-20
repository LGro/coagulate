import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/ui/contact_list/cubit.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:test/test.dart';

void main() {
  test('extractAllValuesToString', () {
    expect(
        extractAllValuesToString({
          'root': {
            'list': [1, 2, 3],
            'string': 'string'
          }
        }),
        '1|2|3|string');
  });
  test('filterAndSortContacts', () {
    final contacts = [
      CoagContact(
          coagContactId: '1',
          details:
              ContactDetails(displayName: 'Daisy', name: Name(first: 'Daisy'))),
    ];
    expect(filterAndSortContacts(contacts, filter: 'name').length, 0);
    expect(filterAndSortContacts(contacts, filter: 'dai').length, 1);
  });
}
