import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/record.dart';
import '../resources/theme.dart';
import 'daily_record_dialog.dart';

class WeeklyCalendar extends StatelessWidget {
  const WeeklyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
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
          const Text('最近两周', style: AppTheme.heading2),
          const SizedBox(height: 12),
          // First week (days 13-7 ago)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = today.subtract(Duration(days: 13 - index));
              return _buildDayCell(context, provider, date, today);
            }),
          ),
          const SizedBox(height: 8),
          // Second week (days 6-0 ago, including today)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = today.subtract(Duration(days: 6 - index));
              return _buildDayCell(context, provider, date, today);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, AppProvider provider, DateTime date, DateTime today) {
    final hasSmoked = _hasSmokedOnDate(provider.records, date);
    final isToday = date.day == today.day && date.month == today.month && date.year == today.year;
    
    return GestureDetector(
      onTap: () => _showDailyDetails(context, provider, date),
      child: Column(
        children: [
          Text(
            DateFormat('E', 'zh').format(date),
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: hasSmoked ? AppTheme.text : (isToday ? AppTheme.primary.withOpacity(0.2) : Colors.grey[200]),
              shape: BoxShape.circle,
              border: isToday ? Border.all(color: AppTheme.primary, width: 2) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: hasSmoked ? Colors.white : (isToday ? AppTheme.primary : Colors.black54),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          if (hasSmoked)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.circle, size: 4, color: AppTheme.text),
            ),
        ],
      ),
    );
  }

  bool _hasSmokedOnDate(List<Record> records, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch ~/ 1000;
    final endOfDay = startOfDay + 86400;
    
    return records.any((r) => 
      r.type == 'smoked' && 
      (r.start ?? 0) >= startOfDay && 
      (r.start ?? 0) < endOfDay
    );
  }

  void _showDailyDetails(BuildContext context, AppProvider provider, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch ~/ 1000;
    final endOfDay = startOfDay + 86400;
    
    final dailyRecords = provider.records.where((r) => 
      (r.start ?? 0) >= startOfDay && 
      (r.start ?? 0) < endOfDay
    ).toList();

    showDialog(
      context: context,
      builder: (context) => DailyRecordDialog(date: date, records: dailyRecords),
    );
  }
}
