import 'settings.state.dart';

class SettingsLogic {
  const SettingsLogic();

  SettingsState fromLocale(String languageCode) {
    return SettingsState(languageCode: languageCode);
  }

  SettingsState setLocale(String languageCode) {
    return SettingsState(languageCode: languageCode);
  }
}
