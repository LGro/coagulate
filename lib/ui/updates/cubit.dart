// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/contact_update.dart';
import '../../data/repositories/contacts.dart';

part 'state.dart';
part 'cubit.g.dart';

class UpdatesCubit extends HydratedCubit<UpdatesState> {
  UpdatesCubit(this.contactsRepository)
      : super(const UpdatesState(UpdatesStatus.initial)) {
    _contactUpdatesSubscription = contactsRepository.getUpdateStatus().listen(
        (event) => emit(UpdatesState(UpdatesStatus.success,
            updates: contactsRepository.updates)));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactUpdatesSubscription;

  Future<void> refresh() => contactsRepository.updateAndWatchReceivingDHT();

  @override
  UpdatesState fromJson(Map<String, dynamic> json) =>
      UpdatesState.fromJson(json);

  @override
  Map<String, dynamic> toJson(UpdatesState state) => state.toJson();

  @override
  Future<void> close() {
    _contactUpdatesSubscription.cancel();
    return super.close();
  }
}
