import 'package:coagulate/ui/locations/page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test number of contacts a location is shared with', () {
    final memberships = {
      'contact1': ['circle2'],
      'contact2': ['circle1', 'circle2']
    };
    expect(numberContactsShared([], []), 0);
    expect(numberContactsShared([[]], []), 0);
    expect(numberContactsShared(memberships.values, []), 0);
    expect(numberContactsShared(memberships.values, ['circle1']), 1);
    expect(numberContactsShared(memberships.values, ['circle3']), 0);
    expect(numberContactsShared(memberships.values, ['circle2']), 2);
    expect(numberContactsShared(memberships.values, ['circle1', 'circle2']), 2);
  });
}
