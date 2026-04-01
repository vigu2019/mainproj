import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static final ValueNotifier<Map<String, String>> profileNotifier = ValueNotifier({
    'name': 'Admin User',
    'email': 'admin@so-yolo.local',
  });

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('admin_name') ?? 'Admin User';
    final email = prefs.getString('admin_email') ?? 'admin@so-yolo.local';
    profileNotifier.value = {'name': name, 'email': email};
  }

  static Future<void> saveProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_name', name);
    await prefs.setString('admin_email', email);
    profileNotifier.value = {'name': name, 'email': email};
  }
}
