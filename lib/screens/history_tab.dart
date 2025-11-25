import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../resources/theme.dart';
import '../l10n/app_strings.dart';
import '../models/record.dart';
import '../widgets/custom_button.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  String _formatDate(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('MMM d, y HH:mm').format(date);
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '';
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final records = provider.records.reversed.toList(); // Show newest first

    return Padding(
      padding: const EdgeInsets.all(AppTheme.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Panel
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
              children: [
                Text(AppStrings.todayStats, style: AppTheme.heading2),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      AppStrings.resistedLabel,
                      '${provider.todayResistedCount}',
                      AppTheme.primary,
                    ),
                    _buildStatItem(
                      AppStrings.durationLabel,
                      '${provider.todayResistedDuration ~/ 60}m',
                      AppTheme.primary,
                    ),
                    _buildStatItem(
                      AppStrings.smokedLabel,
                      '${provider.todaySmokedCount}',
                      AppTheme.text,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Quick Action
          Center(
            child: CustomButton(
              text: AppStrings.logSmokeButton,
              onPressed: () => _showSmokeDialog(context, provider),
              backgroundColor: Colors.grey[300],
              textColor: AppTheme.text,
            ),
          ),
          const SizedBox(height: 20),
          
          // List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('History', style: AppTheme.heading2),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () => _showClearHistoryDialog(context, provider),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // List
          Expanded(
            child: records.isEmpty
                ? const Center(child: Text(AppStrings.historyEmpty))
                : ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final isResisted = record.type == 'resisted';
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            isResisted ? Icons.shield : Icons.smoking_rooms,
                            color: isResisted ? AppTheme.primary : Colors.grey,
                          ),
                          title: Text(
                            isResisted ? AppStrings.resistedLabel : AppStrings.smokedLabel,
                            style: AppTheme.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isResisted ? AppTheme.primary : AppTheme.text,
                            ),
                          ),
                          subtitle: Text(_formatDate(record.start)),
                          trailing: isResisted
                              ? Text(
                                  _formatDuration(record.duration),
                                  style: AppTheme.body.copyWith(fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  record.reason ?? '',
                                  style: AppTheme.body.copyWith(color: Colors.grey),
                                ),
                        ),
                      );
                    },
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
          style: AppTheme.heading2.copyWith(color: color),
        ),
        Text(
          label,
          style: AppTheme.body.copyWith(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _showSmokeDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logSmokeButton),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _reasonButton(context, provider, AppStrings.reasonStress),
            _reasonButton(context, provider, AppStrings.reasonBoredom),
            _reasonButton(context, provider, AppStrings.reasonCraving),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }

  Widget _reasonButton(BuildContext context, AppProvider provider, String reason) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          provider.logSmoke(reason: reason);
          Navigator.pop(context);
        },
        child: Text(reason),
      ),
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
