part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool pushAlerts;
  final bool emailSummaries;
  final bool kitchenSound;
  final bool autoBackup;
  final ThemeMode appearance;

  const SettingsState({
    this.pushAlerts = true,
    this.emailSummaries = false,
    this.kitchenSound = true,
    this.autoBackup = true,
    this.appearance = ThemeMode.light,
  });

  SettingsState copyWith({
    bool? pushAlerts,
    bool? emailSummaries,
    bool? kitchenSound,
    bool? autoBackup,
    ThemeMode? appearance,
  }) {
    return SettingsState(
      pushAlerts: pushAlerts ?? this.pushAlerts,
      emailSummaries: emailSummaries ?? this.emailSummaries,
      kitchenSound: kitchenSound ?? this.kitchenSound,
      autoBackup: autoBackup ?? this.autoBackup,
      appearance: appearance ?? this.appearance,
    );
  }

  @override
  List<Object?> get props => [
        pushAlerts,
        emailSummaries,
        kitchenSound,
        autoBackup,
        appearance,
      ];
}
