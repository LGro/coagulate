// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit(this.contactsRepository)
      : super(const MapState(status: MapStatus.initial)) {
    _profileInfoSubscription = contactsRepository
        .getProfileInfoStream()
        .listen((_) async => refresh());
    _circlesSubscription =
        contactsRepository.getCirclesStream().listen((_) async => refresh());
    // TODO: Does it help the performance significantly to only update the affected contact's data?
    _contactsSubscription = contactsRepository
        .getContactStream()
        .listen((coagContactId) async => refresh());

    unawaited(refresh());
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<void> _circlesSubscription;
  late final StreamSubscription<String> _contactsSubscription;
  late final StreamSubscription<ProfileInfo> _profileInfoSubscription;

  Future<void> refresh() async {
    final profileInfo = contactsRepository.getProfileInfo();
    final circleMemberships = contactsRepository.getCircleMemberships();
    final circles = contactsRepository.getCircles();
    final contacts = contactsRepository.getContacts().values;

    emit(MapState(
      status: MapStatus.success,
      profileInfo: profileInfo,
      contacts: contacts.toList(),
      circleMemberships: circleMemberships,
      circles: circles,
      cachePath: state.cachePath ??
          await getTemporaryDirectory().then((td) => td.path),
    ));
  }

  Future<void> removeLocation(String locationId) async {
    final profileInfo = contactsRepository.getProfileInfo();
    if (profileInfo == null) {
      return;
    }
    await contactsRepository.setProfileInfo(profileInfo.copyWith(
        temporaryLocations: {...profileInfo.temporaryLocations}
          ..remove(locationId)));
  }

  @override
  Future<void> close() {
    _circlesSubscription.cancel();
    _contactsSubscription.cancel();
    _profileInfoSubscription.cancel();
    return super.close();
  }
}
