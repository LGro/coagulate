// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class UpdatesCubit extends HydratedCubit<UpdatesState> {
  UpdatesCubit(this.contactsRepository)
      : super(const UpdatesState(UpdatesStatus.initial)) {
    contactsRepository.getUpdateStatus().listen((event) {});
  }

  final ContactsRepository contactsRepository;

  Future<void> refresh() async {
    print('TODO: Refresh!');
  }

  @override
  UpdatesState fromJson(Map<String, dynamic> json) =>
      UpdatesState.fromJson(json);

  @override
  Map<String, dynamic> toJson(UpdatesState state) => state.toJson();
}
