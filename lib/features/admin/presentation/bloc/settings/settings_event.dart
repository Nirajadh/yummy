part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class PushAlertsToggled extends SettingsEvent {
  final bool value;
  const PushAlertsToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class EmailSummariesToggled extends SettingsEvent {
  final bool value;
  const EmailSummariesToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class KitchenSoundToggled extends SettingsEvent {
  final bool value;
  const KitchenSoundToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class AutoBackupToggled extends SettingsEvent {
  final bool value;
  const AutoBackupToggled(this.value);
  @override
  List<Object?> get props => [value];
}
