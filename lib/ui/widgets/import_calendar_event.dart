// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'searchable_list.dart';

enum _Status { loading, permissionDenied, success }

class CalendarEventsPage extends StatefulWidget {
  const CalendarEventsPage({required this.onSelectEvent, super.key});

  final void Function(Event) onSelectEvent;

  @override
  _CalendarEventsPageState createState() => _CalendarEventsPageState();
}

class _CalendarEventsPageState extends State<CalendarEventsPage>
    with WidgetsBindingObserver {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  List<Calendar> _calendars = [];
  final List<Event> _events = [];
  _Status _status = _Status.loading;
  // Without bookkeeping about when the app went hidden, we run into an infinite
  // loop when trying to detect AppLifecycleState.resumed
  bool _wasHidden = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_retrieveCalendars());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden) {
      setState(() {
        _wasHidden = true;
      });
    } else if (state == AppLifecycleState.resumed &&
        _status == _Status.permissionDenied &&
        _wasHidden) {
      setState(() {
        _wasHidden = false;
      });
      unawaited(_retrieveCalendars());
    }
  }

  Future<void> _retrieveCalendars() async {
    setState(() {
      _status = _Status.loading;
    });

    var calendarPermission = await Permission.calendarFullAccess.status;
    if (calendarPermission.isDenied) {
      calendarPermission = await Permission.calendarFullAccess.request();
    }
    if (calendarPermission.isDenied ||
        calendarPermission.isPermanentlyDenied ||
        calendarPermission.isRestricted) {
      return setState(() {
        _status = _Status.permissionDenied;
      });
    }

    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    setState(() {
      _calendars = calendarsResult.data ?? [];
    });

    final now = DateTime.now();
    for (final calendar in _calendars) {
      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendar.id,
        RetrieveEventsParams(
          startDate: now.subtract(const Duration(days: 30)),
          // look ahead for up to 1 year
          endDate: now.add(const Duration(days: 365)),
        ),
      );

      final filteredEvents = (eventsResult.data ?? [])
          .whereType<Event>()
          .where((event) =>
              event.end != null &&
              event.end!.isAfter(now) &&
              event.recurrenceRule == null)
          .toList();

      if (filteredEvents.isNotEmpty) {
        setState(() {
          _events.addAll(filteredEvents);
          // Or only set this once we covered all calendars?
          _status = _Status.success;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Import from calendar')),
      body: switch (_status) {
        _Status.loading => const Center(child: CircularProgressIndicator()),
        _Status.permissionDenied =>
          const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Center(
                child: Text('No access to calendars.',
                    textScaler: TextScaler.linear(1.2), softWrap: true)),
            SizedBox(height: 16),
            FilledButton.tonal(
                onPressed: openAppSettings, child: Text('Grant permission'))
          ]),
        _Status.success => SearchableList(
            items: _events,
            matchesItem: (s, e) =>
                (_eventTitle(e).toLowerCase().contains(s.toLowerCase())) ||
                (e.location?.toLowerCase().contains(s.toLowerCase()) ?? false),
            buildItemWidget: (e) => ListTile(
                  onTap: () {
                    widget.onSelectEvent(e);
                    context.pop();
                  },
                  title: Text(_eventTitle(e)),
                  subtitle: (e.location == null) ? null : Text(e.location!),
                ))
      });
}

String _eventTitle(Event e) {
  final title = <String>[];
  if (e.start != null) {
    final date = e.start!.toLocal();
    title.add('${DateFormat('MMM').format(date)} ${date.day}');
  }
  title.add(e.title ?? '???');
  return title.join(' | ');
}
