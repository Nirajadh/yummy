import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<AppearanceChanged>((event, emit) {
      emit(state.copyWith(appearance: event.mode));
    });
    on<PushAlertsToggled>((event, emit) {
      emit(state.copyWith(pushAlerts: event.value));
    });
    on<EmailSummariesToggled>((event, emit) {
      emit(state.copyWith(emailSummaries: event.value));
    });
    on<KitchenSoundToggled>((event, emit) {
      emit(state.copyWith(kitchenSound: event.value));
    });
    on<AutoBackupToggled>((event, emit) {
      emit(state.copyWith(autoBackup: event.value));
    });
  }
}
