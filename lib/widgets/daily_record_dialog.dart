import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/record.dart';
import '../resources/theme.dart';

class DailyRecordDialog extends StatelessWidget {
  final DateTime date;
  final List<Record> records;

  const DailyRecordDialog({
    super.key,
    required this.date,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final resistedRecords = records.where((r) => r.type == 'resisted').toList();
    final smokedRecords = records.where((r) => r.type == 'smoked').toList();
    
    final totalResistedDuration = resistedRecords.fold(0, (sum, r) => sum + (r.duration ?? 0));
    final resistedCount = resistedRecords.length;
    final smokedCount = smokedRecords.length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('yyyy年MM月dd日').format(date),
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 20),
            
            // Summary Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('抵御次数', '$resistedCount', AppTheme.primary),
                _buildStat('抵御时长', '${totalResistedDuration ~/ 60}分', AppTheme.primary),
                _buildStat('抽烟数量', '$smokedCount', AppTheme.text),
              ],
            ),
            const Divider(height: 30),
            
            // Timeline
            const Text('详细记录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: records.isEmpty 
                ? const Center(child: Text('无记录'))
                : ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final isResisted = record.type == 'resisted';
                      final time = DateTime.fromMillisecondsSinceEpoch((record.start ?? 0) * 1000);
                      
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isResisted ? Icons.shield : Icons.smoking_rooms,
                          color: isResisted ? AppTheme.primary : Colors.grey,
                          size: 20,
                        ),
                        title: Text(
                          isResisted ? '抵御成功' : '抽了一根',
                          style: TextStyle(
                            color: isResisted ? AppTheme.primary : AppTheme.text,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(DateFormat('HH:mm').format(time)),
                        trailing: isResisted
                            ? Text('${record.duration ?? 0}秒')
                            : Text(record.reason ?? ''),
                      );
                    },
                  ),
            ),
            
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
