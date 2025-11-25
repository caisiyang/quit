import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/grade_system.dart';
import '../resources/theme.dart';
import '../l10n/app_strings.dart';

class GradeDetailsDialog extends StatelessWidget {
  const GradeDetailsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final currentGrade = provider.currentGrade;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('等级详情', style: AppTheme.heading2),
            const SizedBox(height: 10),
            Text('当前等级: $currentGrade', style: AppTheme.body.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary)),
            const SizedBox(height: 20),
            Text('下一个目标:', style: AppTheme.body.copyWith(fontWeight: FontWeight.bold)),
            Text(provider.nextGoalText, style: AppTheme.body),
            const SizedBox(height: 20),
            Text('等级规则:', style: AppTheme.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: GradeSystem.grades.length,
                itemBuilder: (context, index) {
                  final grade = GradeSystem.grades[index];
                  final threshold = GradeSystem.getThreshold(grade);
                  String durationText = '';
                  if (threshold < 60) durationText = '$threshold秒';
                  else if (threshold < 3600) durationText = '${threshold ~/ 60}分钟';
                  else durationText = '${threshold ~/ 3600}小时';
                  
                  final isCurrent = grade == currentGrade;

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: isCurrent ? AppTheme.primary.withOpacity(0.1) : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(grade, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                        Text(durationText, style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(AppStrings.ok),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
