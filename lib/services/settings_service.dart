import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError();
});

class SettingsService {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static const String _keyVibration = 'vibration_enabled';
  static const String _keySound = 'sound_enabled';
  static const String _keyTaskReminders = 'task_reminders_enabled';
  static const String _keyPushNotifications = 'push_notifications_enabled';

  static const String _keyDailyReminderTime = 'daily_reminder_time';

  bool get vibrationEnabled => _prefs.getBool(_keyVibration) ?? true;
  bool get soundEnabled => _prefs.getBool(_keySound) ?? true;
  bool get taskRemindersEnabled => _prefs.getBool(_keyTaskReminders) ?? true;
  bool get pushNotificationsEnabled =>
      _prefs.getBool(_keyPushNotifications) ?? true;
  String? get dailyReminderTime => _prefs.getString(_keyDailyReminderTime);

  Future<void> setVibrationEnabled(bool value) =>
      _prefs.setBool(_keyVibration, value);
  Future<void> setSoundEnabled(bool value) => _prefs.setBool(_keySound, value);
  Future<void> setTaskRemindersEnabled(bool value) =>
      _prefs.setBool(_keyTaskReminders, value);
  Future<void> setPushNotificationsEnabled(bool value) =>
      _prefs.setBool(_keyPushNotifications, value);

  Future<void> setDailyReminderTime(String? timeString) {
    if (timeString == null) return _prefs.remove(_keyDailyReminderTime);
    return _prefs.setString(_keyDailyReminderTime, timeString);
  }
}
