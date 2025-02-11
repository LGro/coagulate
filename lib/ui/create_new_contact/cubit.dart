// Copyright 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cubit.g.dart';
part 'state.dart';

class CreateNewcontactCubit extends Cubit<CreateNewcontactState> {
  CreateNewcontactCubit() : super(const CreateNewcontactState());

  void updateName(String name) => emit(state.copyWith(name: name));
}
