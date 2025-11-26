import 'record.dart';

class GradeSystem {
  // Constants for Thresholds (Seconds)
  static const int C10 = 60;
  static const int C9 = 120;
  static const int C8 = 180;
  static const int C7 = 300;
  static const int C6 = 600;
  static const int C5 = 1800;
  static const int C4 = 3600;
  static const int C3 = 7200;
  static const int C2 = 21600;
  static const int C1 = 43200;

  // Grade Levels
  static const List<String> grades = [
    'C10', 'C9', 'C8', 'C7', 'C6', 'C5', 'C4', 'C3', 'C2', 'C1',
    'C', 'B', 'A', 'S', 'SS', 'SSS'
  ];

  static const int PROMOTION_STREAK = 3;
  static const int DEMOTION_STREAK = 2;

  // Helper to get threshold for a grade
  static int getThreshold(String grade) {
    switch (grade) {
      case 'C10': return C10;
      case 'C9': return C9;
      case 'C8': return C8;
      case 'C7': return C7;
      case 'C6': return C6;
      case 'C5': return C5;
      case 'C4': return C4;
      case 'C3': return C3;
      case 'C2': return C2;
      case 'C1': return C1;
      default: return C1; // For higher grades, threshold stays at C1 max or custom logic
    }
  }

  // Evaluate Progress
  // This is a simplified version for MVP.
  // Real implementation would need to look at N days history.
  // Here we just check the last few days based on provided records.
  static String evaluate(List<Record> records, String currentGrade) {
    // Sort records by time
    records.sort((a, b) => (b.start ?? 0).compareTo(a.start ?? 0)); // Descending

    // Group by day
    // ... (Implementation complexity omitted for brevity in this step, but will be needed)
    // For MVP, we might simplify:
    // If today is success -> increment streak.
    // If streak >= PROMOTION_STREAK -> promote.
    
    // Returning current grade for now to be safe until full logic is implemented in Provider
    return currentGrade;
  }
  
  static bool isSuccessDay(List<Record> dayRecords, String currentGrade) {
    if (dayRecords.any((r) => r.type == 'smoked')) return false;
    
    int threshold = getThreshold(currentGrade);
    // Success if at least one resisted record >= threshold
    return dayRecords.any((r) => r.type == 'resisted' && (r.duration ?? 0) >= threshold);
  }
  static String getHealthBenefit(String grade) {
    switch (grade) {
      case 'C10': return '心率开始平复，血压轻微下降。';
      case 'C9': return '焦虑感开始减弱，深呼吸让氧气水平回升。';
      case 'C8': return '手脚温度开始回升，血液循环改善。';
      case 'C7': return '强烈的尼古丁渴望达到顶峰后开始消退。';
      case 'C6': return '大脑多巴胺水平波动趋于平稳，情绪更稳定。';
      case 'C5': return '血压和脉搏恢复正常水平。';
      case 'C4': return '血液中的尼古丁含量减半，身体开始清理毒素。';
      case 'C3': return '血液中氧气含量恢复正常，一氧化碳水平下降。';
      case 'C2': return '神经末梢开始再生，嗅觉和味觉变得敏锐。';
      case 'C1': return '血液中一氧化碳含量恢复正常水平。';
      default: return '持续的自我掌控，显著降低心脏病风险，肺功能开始改善。';
    }
  }
}
