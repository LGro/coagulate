// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cubit.g.dart';
part 'state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(const SettingsState(
            message: '',
            status: SettingsStatus.initial,
            darkMode: false,
            autoAddressResolution: true,
            mapProvider: 'mapbox'));
}
