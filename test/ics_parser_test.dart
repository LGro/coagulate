import 'package:coagulate/ics_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filter details list, no active circles', () {
    const ics = r'''
BEGIN:VCALENDAR
VERSION:2.0
CALSCALE:GREGORIAN
METHOD:REQUEST
PRODID:-//Calendar//org.lineageos.etar
BEGIN:VEVENT
LOCATION:Paris\, France
UID:f183db3a-3991-48e8-b509-b86f8ee4fde7@org.lineageos.etar
DTSTAMP:20250529T072156Z
SUMMARY:Test
DTSTART:20250529T070000Z
DESCRIPTION:Detailed description
DTEND:20250529T080201Z
ORGANIZER;CN=Offline Calendar:mailto:Offline Calendar
END:VEVENT
END:VCALENDAR
''';
    DateTime.now().toUtc().toIso8601String();
    final event = parseIcsEvent(ics);
    expect(event?.summary, 'Test');
    expect(event?.description, 'Detailed description');
    expect(event?.location, 'Paris, France');
    expect(event?.end, DateTime.utc(2025, 05, 29, 08, 2, 1));
  });
}
