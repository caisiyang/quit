import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/record.dart';

class PersistenceHelper {
  static const String KEY_RECORDS = 'records';
  static const String KEY_GRADE = 'current_grade';
  static const String KEY_LAST_EVALUATION = 'last_evaluation_time';

  static Future<void> saveRecords(List<Record> records) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(KEY_RECORDS, jsonString);
  }

  static Future<List<Record>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(KEY_RECORDS);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Record.fromJson(json)).toList();
  }

  static Future<void> saveGrade(String grade) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_GRADE, grade);
  }

  static Future<String> loadGrade() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_GRADE) ?? 'C10';
  }
}
