import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static const String _scansKey = 'total_scans';

  // Get current total scans 
  static Future<int> getTotalScans() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_scansKey) ?? 0;
  }

  // Increment total scans by 1
  static Future<void> incrementScans() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_scansKey) ?? 0;
    await prefs.setInt(_scansKey, current + 1);
  }
}
