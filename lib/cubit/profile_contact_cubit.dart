// Copyright 2024 Lukas Grossberger
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

part 'profile_contact_cubit.g.dart';
part 'profile_contact_state.dart';

// TODO: Add contact refresh as listener via
//       FlutterContacts.addListener(() => print('Contact DB changed'));

class ProfileContactCubit extends HydratedCubit<ProfileContactState> {
  ProfileContactCubit() : super(ProfileContactState());

  // TODO: Separate the emits out?
  Future<void> updateContact() async {
    emit(state.copyWith(status: ProfileContactStatus.loading));

    if (state.profileContact == null) {
      emit(state.copyWith(status: ProfileContactStatus.unavailable));
      return;
    }

    emit(state.copyWith(
        status: ProfileContactStatus.success,
        profileContact:
            await FlutterContacts.getContact(state.profileContact!.id)));
  }

  void setContact(Contact? contact) {
    emit(state.copyWith(
        status: (contact == null)
            ? ProfileContactStatus.unavailable
            : ProfileContactStatus.success,
        profileContact: contact));
  }

  @override
  ProfileContactState fromJson(Map<String, dynamic> json) =>
      ProfileContactState.fromJson(json);

  @override
  Map<String, dynamic> toJson(ProfileContactState state) => state.toJson();
}
