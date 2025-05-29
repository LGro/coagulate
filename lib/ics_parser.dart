// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ics_parser.freezed.dart';

@freezed
class IcsEvent with _$IcsEvent {
  IcsEvent({
    required this.start,
    required this.end,
    required this.summary,
    this.location,
    this.description,
  });

  final DateTime start;
  final DateTime end;
  final String summary;
  final String? location;
  final String? description;
}

DateTime? parseIcsUtcDateTime(String dt) {
  if (dt.length != 16) {
    return null;
  }
  if (!dt.endsWith('Z')) {
    return null;
  }
  final year = int.tryParse(dt.substring(0, 4));
  final month = int.tryParse(dt.substring(4, 6));
  final day = int.tryParse(dt.substring(6, 8));
  final hours = int.tryParse(dt.substring(9, 11));
  final minutes = int.tryParse(dt.substring(11, 13));
  final seconds = int.tryParse(dt.substring(13, 15));
  if (year == null ||
      month == null ||
      day == null ||
      hours == null ||
      minutes == null ||
      seconds == null) {
    return null;
  }
  return DateTime.utc(year, month, day, hours, minutes, seconds);
}

IcsEvent? parseIcsEvent(String icsData) {
  final lines = icsData.split('\n');
  String? summary;
  DateTime? dtStart;
  DateTime? dtEnd;
  String? location;
  String? description;

  for (var line in lines) {
    line = line.trim();
    if (line.startsWith('SUMMARY:')) {
      summary = line.substring('SUMMARY:'.length);
    } else if (line.startsWith('DTSTART:')) {
      dtStart = parseIcsUtcDateTime(line.substring('DTSTART:'.length));
    } else if (line.startsWith('DTEND:')) {
      dtEnd = parseIcsUtcDateTime(line.substring('DTEND:'.length));
    } else if (line.startsWith('LOCATION:')) {
      location = line.substring('LOCATION:'.length).replaceAll(r'\,', ',');
    } else if (line.startsWith('DESCRIPTION:')) {
      description = line.substring('DESCRIPTION:'.length);
    }
  }

  if (summary != null && dtStart != null && dtEnd != null) {
    return IcsEvent(
      start: dtStart,
      end: dtEnd,
      summary: summary,
      location: location,
      description: description,
    );
  }

  return null;
}
