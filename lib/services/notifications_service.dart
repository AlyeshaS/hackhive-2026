import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsService extends ChangeNotifier {
  static const _key = 'notifications_enabled';

  bool _enabled = true;
  bool get enabled => _enabled;

  NotificationsService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_key) ?? true;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);

    // TODO: When you integrate flutter_local_notifications, call:
    // if (value) { await _flutterLocalNotifications.resolvePlatformSpecificImplementation... }
    // else { await _flutterLocalNotifications.cancelAll(); }
  }
}