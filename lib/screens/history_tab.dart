import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../resources/theme.dart';
import '../l10n/app_strings.dart';
import '../models/record.dart';
import '../widgets/custom_button.dart';

import '../widgets/weekly_calendar.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('抽烟记录', style: AppTheme.heading1),
          const SizedBox(height: 20),

          // Today's Record Card
          Container(
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
                const Text('今日记录', style: AppTheme.heading2),
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
          const SizedBox(height: 30),
          
          // Weekly Calendar
          const WeeklyCalendar(),
          
          const Spacer(),
          // You might want to keep the clear history button somewhere, or maybe not if it wasn't requested in the new design.
          // The user asked to "change the whole thing to a 1 week calendar".
          // I'll leave a small clear button at the bottom just in case.
          Center(
            child: TextButton.icon(
              onPressed: () => _showClearHistoryDialog(context, Provider.of<AppProvider>(context, listen: false)),
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              label: const Text('清空所有记录', style: TextStyle(color: Colors.grey)),
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
}
