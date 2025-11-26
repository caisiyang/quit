import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../resources/theme.dart';
import '../l10n/app_strings.dart';
import '../models/record.dart';
import '../widgets/custom_button.dart';
import '../widgets/weekly_calendar.dart';
import '../widgets/rotating_quote_card.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('抽烟记录', style: AppTheme.heading1),
          const SizedBox(height: 20),

          // Today's Record Card
          GestureDetector(
            onTap: () => _showDailyDetails(context, Provider.of<AppProvider>(context, listen: false)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('今日记录', style: AppTheme.heading2),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('抵御次数', '${Provider.of<AppProvider>(context).todayResistedCount}', AppTheme.primary),
                      _buildStatItem('抵御时长', '${Provider.of<AppProvider>(context).todayResistedDuration ~/ 60}分', AppTheme.primary),
                      _buildStatItem('抽烟根数', '${Provider.of<AppProvider>(context).todaySmokedCount}', AppTheme.text),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Weekly Calendar
          const WeeklyCalendar(),
          
          const SizedBox(height: 20),
          
          // Urge Surfing Principle Card
          const Text('关于本app烟瘾海浪原理', style: AppTheme.heading2),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '烟瘾就像海浪',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                const SizedBox(height: 10),
                const Text(
                  '科学研究表明，每次烟瘾来袭时的强烈渴望通常只会持续 5 到 10 分钟。就像海浪一样，它会高涨，达到顶峰，但最终一定会消退。\n\n你不需要痛苦地对抗它，只需要像冲浪者一样，观察它，感受它，等待它自然过去。',
                  style: AppTheme.body,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb, color: AppTheme.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '每一次的成功抵御，都是对大脑奖赏回路的一次重塑。坚持下去，你正在一步步夺回对自己生活的掌控权！',
                          style: TextStyle(fontSize: 14, color: AppTheme.text, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _showClearHistoryDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: const Text(AppStrings.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
            },
            child: const Text(AppStrings.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDailyDetails(BuildContext context, AppProvider provider) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 1000;
    final todayEnd = todayStart + 86400;
    
    final todayRecords = provider.records
        .where((r) => (r.start ?? 0) >= todayStart && (r.start ?? 0) < todayEnd)
        .toList();
    
    // Sort by time descending
    todayRecords.sort((a, b) => (b.start ?? 0).compareTo(a.start ?? 0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('今日详细记录'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: todayRecords.isEmpty
              ? const Center(child: Text('暂无记录'))
              : ListView.builder(
                  itemCount: todayRecords.length,
                  itemBuilder: (context, index) {
                    final record = todayRecords[index];
                    final date = DateTime.fromMillisecondsSinceEpoch((record.start ?? 0) * 1000);
                    final timeStr = DateFormat('HH:mm').format(date);
                    final isSmoked = record.type == 'smoked';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSmoked ? Colors.grey[100] : AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSmoked ? Colors.grey[300]! : AppTheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            timeStr,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSmoked ? '抽烟' : '抵御成功',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSmoked ? AppTheme.text : AppTheme.primary,
                                  ),
                                ),
                                if (isSmoked && record.reason != null)
                                  Text(
                                    '原因: ${record.reason}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                if (!isSmoked)
                                  Text(
                                    '时长: ${record.duration != null ? (record.duration! ~/ 60) : 0}分钟',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }
}
