// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class CircleDetailsCubit extends Cubit<CircleDetailsState> {
  CircleDetailsCubit(this.contactsRepository, [String? circleId])
      : super(const CircleDetailsState(CircleDetailsStatus.initial)) {
    _circlesSubscription = contactsRepository.getCirclesStream().listen((_) {
      if (!isClosed) {
        emit(state.copyWith(
            circleMemberships: contactsRepository.getCircleMemberships(),
            circles: contactsRepository.getCircles()));
      }
    });
    _profileInfoSubscription =
        contactsRepository.getProfileInfoStream().listen((profileInfo) {
      if (!isClosed) {
        emit(state.copyWith(profileInfo: profileInfo));
      }
    });

    final circleMemberships = contactsRepository.getCircleMemberships();
    final contacts = contactsRepository.getContacts().values.toList()
      ..sortBy((c) => c.name.toLowerCase());
    emit(CircleDetailsState(CircleDetailsStatus.success,
        circleId: circleId,
        profileInfo: contactsRepository.getProfileInfo(),
        circles: contactsRepository.getCircles(),
        circleMemberships: circleMemberships,
        contacts: [
          // Circle members
          ...contacts.where((c) =>
              circleMemberships[c.coagContactId]?.contains(circleId) ?? false),
          // Not circle members
          ...contacts.where((c) =>
              !(circleMemberships[c.coagContactId]?.contains(circleId) ??
                  false)),
        ]));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<void> _circlesSubscription;
  late final StreamSubscription<ProfileInfo> _profileInfoSubscription;

  Future<void> updateCircleMembership(
          String coagContactId, bool member) async =>
      (state.circleId == null)
          ? null
          : contactsRepository.updateCirclesForContact(
              coagContactId,
              member
                  ? [
                      ...(state.circleMemberships[coagContactId] ?? []),
                      state.circleId!
                    ]
                  : ([...(state.circleMemberships[coagContactId] ?? [])]
                    ..remove(state.circleId)));

  Future<void> updateCirclePicture(List<int>? picture) async {
    if (state.profileInfo == null || state.circleId == null) {
      return;
    }

    final pictures = {...state.profileInfo!.pictures};
    if (picture == null) {
      pictures.remove(state.circleId);
    } else {
      pictures[state.circleId!] = picture;
    }

    await contactsRepository
        .setProfileInfo(state.profileInfo!.copyWith(pictures: pictures));
  }

  Future<void> updateLocationSharing(String locationId, bool doShare) async {
    if (state.profileInfo == null ||
        state.circleId == null ||
        !state.profileInfo!.temporaryLocations.containsKey(locationId)) {
      return;
    }

    final temporaryLocations = {...state.profileInfo!.temporaryLocations};
    if (doShare) {
      temporaryLocations[locationId] = temporaryLocations[locationId]!.copyWith(
          circles: {...temporaryLocations[locationId]!.circles, state.circleId!}
              .toList());
    } else {
      temporaryLocations[locationId] = temporaryLocations[locationId]!.copyWith(
          circles: {...temporaryLocations[locationId]!.circles}.toList()
            ..remove(state.circleId));
    }

    await contactsRepository.setProfileInfo(
        state.profileInfo!.copyWith(temporaryLocations: temporaryLocations));
  }

  @override
  Future<void> close() {
    _circlesSubscription.cancel();
    _profileInfoSubscription.cancel();
    return super.close();
  }
}
