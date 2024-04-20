// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cubit.g.dart';
part 'state.dart';

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit(super.state);

  @override
  SettingsState fromJson(Map<String, dynamic> json) =>
      SettingsState.fromJson(json);

  @override
  Map<String, dynamic> toJson(SettingsState state) => state.toJson();

  Future<void> updateMessage() async {
    final _sharedPreference = await SharedPreferences.getInstance();
    final bgLog = _sharedPreference.getString('bgLog');
    emit(SettingsState(
        status: SettingsStatus.success, message: (bgLog == null) ? '' : bgLog));
  }
}
