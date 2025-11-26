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
    // Generate last 7 days including today
    final weekDates = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text('最近一周', style: AppTheme.heading2),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDates.map((date) {
            final hasSmoked = _hasSmokedOnDate(provider.records, date);
            final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
            
            return GestureDetector(
              onTap: () => _showDailyDetails(context, provider, date),
              child: Column(
                children: [
                  Text(
                    DateFormat('E', 'zh').format(date), // Weekday
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 40,
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
                      ),
                    ),
                  ),
                  if (hasSmoked)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.circle, size: 6, color: AppTheme.text),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
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
