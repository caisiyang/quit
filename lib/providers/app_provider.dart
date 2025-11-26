import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/record.dart';
import '../models/grade_system.dart';
import '../models/user_profile.dart';
import '../services/persistence_helper.dart';
import '../resources/assets_loader.dart';

class AppProvider with ChangeNotifier {
  List<Record> _records = [];
  String _currentGrade = 'C10';
  
  // Surfing State
  bool _isSurfing = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  String _currentQuote = "Breathe.";
  List<String> _quotes = [];
  List<String> _facts = [];
  UserProfile _userProfile = UserProfile();
  int _currentThemeIndex = 0;
  int _currentAnimationMode = 0; // 0: Breathing, 1: Glow, 2: Rainbow

  // Getters
  List<Record> get records => _records;
  String get currentGrade => _currentGrade;
  bool get isSurfing => _isSurfing;
  int get elapsedSeconds => _elapsedSeconds;
  String get currentQuote => _currentQuote;
  List<String> get facts => _facts;
  List<String> get quotes => _quotes;
  UserProfile get userProfile => _userProfile;
  int get currentThemeIndex => _currentThemeIndex;
  int get currentAnimationMode => _currentAnimationMode;

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    _records = await PersistenceHelper.loadRecords();
    _currentGrade = await PersistenceHelper.loadGrade();
    _quotes = await AssetsLoader.loadQuotes();
    _facts = await AssetsLoader.loadFacts();
    _userProfile = await PersistenceHelper.loadUserProfile();
    _currentThemeIndex = await PersistenceHelper.loadTheme();
    _currentAnimationMode = await PersistenceHelper.loadAnimationMode();
    
    // Generate dummy data if empty (for testing/demo)
    if (_records.isEmpty) {
      _generateDummyData();
    }
    
    notifyListeners();
  }

  void setTheme(int index) {
    _currentThemeIndex = index;
    PersistenceHelper.saveTheme(index);
    notifyListeners();
  }

  void setAnimationMode(int mode) {
    _currentAnimationMode = mode;
    PersistenceHelper.saveAnimationMode(mode);
    notifyListeners();
  }

  void updateUserProfile(UserProfile newProfile) {
    _userProfile = newProfile;
    PersistenceHelper.saveUserProfile(_userProfile);
    notifyListeners();
  }

  void failSurfing(String reason) {
    _timer?.cancel();
    _isSurfing = false;
    
    final record = Record.smoked(
      reason: reason,
      duration: _elapsedSeconds,
    );
    _records.add(record);
    PersistenceHelper.saveRecords(_records);
    
    _elapsedSeconds = 0;
    notifyListeners();
  }

  void _generateDummyData() {
    final now = DateTime.now();
    final random = Random();
    _records.clear(); // Clear existing to ensure we have fresh 3 days data
    
    for (int i = 0; i < 3; i++) {
      final date = now.subtract(Duration(days: i));
      
      // 1. Normal Smoked Records (No surfing)
      int directSmokedCount = 10 + random.nextInt(5); 
      for (int j = 0; j < directSmokedCount; j++) {
        final hour = 8 + random.nextInt(14);
        final minute = random.nextInt(60);
        final recordTime = DateTime(date.year, date.month, date.day, hour, minute);
        
        _records.add(Record.smoked(
          start: recordTime.millisecondsSinceEpoch ~/ 1000,
          reason: ['习惯', '社交', '饭后'][random.nextInt(3)],
        ));
      }
      
      // 2. Failed Surfing Records (Smoked after resisting)
      int failedSurfingCount = 3 + random.nextInt(3);
      for (int j = 0; j < failedSurfingCount; j++) {
        final hour = 8 + random.nextInt(14);
        final minute = random.nextInt(60);
        final recordTime = DateTime(date.year, date.month, date.day, hour, minute);
        final duration = 30 + random.nextInt(120); // Resisted 30s - 2m then smoked
        
        _records.add(Record.smoked(
          start: recordTime.millisecondsSinceEpoch ~/ 1000,
          duration: duration,
          reason: '没忍住',
        ));
      }
      
      // 3. Successful Surfing Records (Resisted)
      int resistedCount = 5 + random.nextInt(5);
      for (int j = 0; j < resistedCount; j++) {
         final hour = 8 + random.nextInt(14);
         final minute = random.nextInt(60);
         final recordTime = DateTime(date.year, date.month, date.day, hour, minute);
         final duration = 300 + random.nextInt(600); // 5-15 minutes
         
         _records.add(Record.resisted(
           start: recordTime.millisecondsSinceEpoch ~/ 1000,
           end: (recordTime.millisecondsSinceEpoch ~/ 1000) + duration,
           duration: duration,
         ));
      }
    }
    // Sort records by time
    _records.sort((a, b) => (a.start ?? 0).compareTo(b.start ?? 0));
    PersistenceHelper.saveRecords(_records);
  }

  // Surfing Logic
  void startSurfing() {
    _isSurfing = true;
    _elapsedSeconds = 0;
    _updateQuote();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      if (_elapsedSeconds % 5 == 0) {
        _updateQuote();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void stopSurfing() {
    if (!_isSurfing) return;
    
    _timer?.cancel();
    _isSurfing = false;
    
    // Create Record
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final start = now - _elapsedSeconds;
    final record = Record.resisted(start: start, end: now);
    
    _addRecord(record);
    notifyListeners();
  }

  void _updateQuote() {
    if (_quotes.isNotEmpty) {
      _currentQuote = _quotes[Random().nextInt(_quotes.length)];
    }
  }

  // History Logic
  void logSmoke({String? reason, DateTime? timestamp}) {
    final record = Record.smoked(
      reason: reason,
      start: timestamp != null ? timestamp.millisecondsSinceEpoch ~/ 1000 : null,
    );
    _addRecord(record);
  }

  void _addRecord(Record record) {
    _records.add(record);
    PersistenceHelper.saveRecords(_records);
    _evaluateGrade();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _records.clear();
    await PersistenceHelper.saveRecords(_records);
    notifyListeners();
  }

  // Grade Logic
  void _evaluateGrade() {
    // Simplified evaluation for MVP
    // In a real app, this would check streaks and promote/demote
    // For now, we just save the grade if it changes (logic placeholder)
    String newGrade = GradeSystem.evaluate(_records, _currentGrade);
    if (newGrade != _currentGrade) {
      _currentGrade = newGrade;
      PersistenceHelper.saveGrade(_currentGrade);
    }
  }

  // Stats Helpers
  int get todayResistedCount {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 1000;
    return _records.where((r) => r.type == 'resisted' && (r.start ?? 0) >= todayStart).length;
  }

  int get todayResistedDuration {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 1000;
    return _records
        .where((r) => r.type == 'resisted' && (r.start ?? 0) >= todayStart)
        .fold(0, (sum, r) => sum + (r.duration ?? 0));
  }

  int get todaySmokedCount {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 1000;
    return _records.where((r) => r.type == 'smoked' && (r.start ?? 0) >= todayStart).length;
  }

  // Streak Logic
  int get currentStreak {
    // Simplified streak calculation for MVP
    // In a real app, this would check consecutive days of success
    // For now, we'll just return a placeholder or calculate based on recent records
    // Let's count consecutive days with at least one resisted record and no smoked records
    int streak = 0;
    final now = DateTime.now();
    
    // Check up to 30 days back
    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day).millisecondsSinceEpoch ~/ 1000;
      final dayEnd = dayStart + 86400;
      
      final dayRecords = _records.where((r) => (r.start ?? 0) >= dayStart && (r.start ?? 0) < dayEnd).toList();
      
      if (GradeSystem.isSuccessDay(dayRecords, _currentGrade)) {
        streak++;
      } else {
        // If it's today and we haven't failed yet (just no success yet), don't break streak if yesterday was success
        // But for simplicity, let's just break if not success
        if (i == 0 && dayRecords.isEmpty) {
           // Today is empty, don't count it as break yet, but don't add to streak
           continue;
        }
        break;
      }
    }
    return streak;
  }

  String get nextGoalText {
    int target = GradeSystem.PROMOTION_STREAK;
    int current = currentStreak;
    int threshold = GradeSystem.getThreshold(_currentGrade);
    String durationText = '';
    if (threshold < 60) durationText = '$threshold秒';
    else if (threshold < 3600) durationText = '${threshold ~/ 60}分钟';
    else durationText = '${threshold ~/ 3600}小时';

    return '当前需连续 $target 天抵御 $durationText 的冲动，已完成 $current/$target 天';
  }
}
