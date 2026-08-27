class SettingsState {
  final String languageCode;

  const SettingsState({this.languageCode = 'en'});

  SettingsState copyWith({String? languageCode}) {
    return SettingsState(languageCode: languageCode ?? this.languageCode);
  }
}
