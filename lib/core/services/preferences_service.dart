import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class PreferencesService {
  static const String _kRole = 'pref_role';
  static const String _kLanguage = 'pref_language';
  static const String _kThemeMode = 'pref_theme_mode';

  static const String roleFarmer = 'farmer';
  static const String roleOwner = 'owner';

  static const String themeLight = 'light';
  static const String themeDark = 'dark';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String?> getRole() async => (await _prefs).getString(_kRole);

  Future<void> setRole(String role) async {
    await (await _prefs).setString(_kRole, role);
  }

  Future<String> getLanguage() async =>
      (await _prefs).getString(_kLanguage) ?? 'English';

  Future<void> setLanguage(String language) async {
    await (await _prefs).setString(_kLanguage, language);
  }

  Future<String> getThemeMode() async =>
      (await _prefs).getString(_kThemeMode) ?? themeLight;

  Future<void> setThemeMode(String mode) async {
    await (await _prefs).setString(_kThemeMode, mode);
  }

  Future<bool> isDarkMode() async => (await getThemeMode()) == themeDark;

  Future<void> setDarkMode(bool isDark) async {
    await setThemeMode(isDark ? themeDark : themeLight);
  }

  Future<void> clear() async {
    final p = await _prefs;
    await Future.wait([
      p.remove(_kRole),
      p.remove(_kLanguage),
      p.remove(_kThemeMode),
    ]);
  }
}
