import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class PreferencesService {
  static const String _kRole = 'pref_role';
  static const String _kLanguage = 'pref_language';
  static const String _kCurrency = 'pref_currency';
  static const String _kPushNotifications = 'pref_push_notifications';
  static const String _kEmailNotifications = 'pref_email_notifications';
  static const String _kSmsNotifications = 'pref_sms_notifications';

  static const String roleFarmer = 'farmer';
  static const String roleOwner = 'owner';

  static const List<String> languages = [
    'English',
    'Kinyarwanda',
    'Français',
    'Kiswahili',
  ];

  static const List<String> currencies = ['RWF', 'USD', 'EUR'];

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

  Future<String> getCurrency() async =>
      (await _prefs).getString(_kCurrency) ?? 'RWF';

  Future<void> setCurrency(String currency) async {
    await (await _prefs).setString(_kCurrency, currency);
  }

  Future<bool> getPushNotifications() async =>
      (await _prefs).getBool(_kPushNotifications) ?? true;

  Future<void> setPushNotifications(bool enabled) async {
    await (await _prefs).setBool(_kPushNotifications, enabled);
  }

  Future<bool> getEmailNotifications() async =>
      (await _prefs).getBool(_kEmailNotifications) ?? true;

  Future<void> setEmailNotifications(bool enabled) async {
    await (await _prefs).setBool(_kEmailNotifications, enabled);
  }

  Future<bool> getSmsNotifications() async =>
      (await _prefs).getBool(_kSmsNotifications) ?? false;

  Future<void> setSmsNotifications(bool enabled) async {
    await (await _prefs).setBool(_kSmsNotifications, enabled);
  }

  Future<void> clear() async {
    final p = await _prefs;
    await Future.wait([
      p.remove(_kRole),
      p.remove(_kLanguage),
      p.remove(_kCurrency),
      p.remove(_kPushNotifications),
      p.remove(_kEmailNotifications),
      p.remove(_kSmsNotifications),
    ]);
  }
}
