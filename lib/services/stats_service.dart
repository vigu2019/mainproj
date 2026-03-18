import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static const String _scansKey = 'total_scans';

  // Get current total scans 
  static Future<int> getTotalScans() async {
    final prefs = await SharedPreferences.getInstance();
    // Start with 22 instead of 1248 default
    return prefs.getInt(_scansKey) ?? 22;
  }

  // Increment total scans by 1
  static Future<void> incrementScans() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_scansKey) ?? 22;
    await prefs.setInt(_scansKey, current + 1);
  }
}
