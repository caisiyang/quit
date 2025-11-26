import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/record.dart';
import '../models/user_profile.dart';

class PersistenceHelper {
  static const String _keyRecords = 'records';
  static const String _keyGrade = 'current_grade';
  static const String keyLastEvaluation = 'last_evaluation_time';

  static Future<void> saveRecords(List<Record> records) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(_keyRecords, jsonString);
  }

  static Future<List<Record>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyRecords);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Record.fromJson(json)).toList();
  }

  static Future<void> saveGrade(String grade) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGrade, grade);
  }

  static Future<String> loadGrade() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyGrade) ?? 'C10';
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(profile.toJson());
    await prefs.setString('user_profile', jsonString);
  }

  static Future<UserProfile> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('user_profile');
    if (jsonString == null) return UserProfile();
    return UserProfile.fromJson(jsonDecode(jsonString));
  }

  static Future<void> saveTheme(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_index', index);
  }

  static Future<int> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('theme_index') ?? 0;
  }

  static Future<void> saveAnimationMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('animation_mode', mode);
  }

  static Future<int> loadAnimationMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('animation_mode') ?? 0;
  }
}
