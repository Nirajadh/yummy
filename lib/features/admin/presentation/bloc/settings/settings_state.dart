part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool pushAlerts;
  final bool emailSummaries;
  final bool kitchenSound;
  final bool autoBackup;

  const SettingsState({
    this.pushAlerts = true,
    this.emailSummaries = false,
    this.kitchenSound = true,
    this.autoBackup = true,
  });

  SettingsState copyWith({
    bool? pushAlerts,
    bool? emailSummaries,
    bool? kitchenSound,
    bool? autoBackup,
  }) {
    return SettingsState(
      pushAlerts: pushAlerts ?? this.pushAlerts,
      emailSummaries: emailSummaries ?? this.emailSummaries,
      kitchenSound: kitchenSound ?? this.kitchenSound,
      autoBackup: autoBackup ?? this.autoBackup,
    );
  }

  @override
  List<Object?> get props => [pushAlerts, emailSummaries, kitchenSound, autoBackup];
}
