import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../resources/theme.dart';
import '../models/grade_system.dart';
import '../l10n/app_strings.dart';
import '../widgets/custom_button.dart';
import '../widgets/grade_details_dialog.dart';
import '../widgets/rotating_quote_card.dart';
import '../widgets/surfing_button.dart';

class SurfingTab extends StatefulWidget {
  const SurfingTab({super.key});

  @override
  State<SurfingTab> createState() => _SurfingTabState();
}

class _SurfingTabState extends State<SurfingTab> {
  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double _getProgress(AppProvider provider) {
    final threshold = GradeSystem.getThreshold(provider.currentGrade);
    if (threshold == 0) return 0.0;
    final progress = provider.elapsedSeconds / threshold;
    
    // Check if we just reached the threshold
    if (progress >= 1.0 && !_celebrationShown) {
      _celebrationShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCelebration(context, provider);
      });
    }
    
    return progress > 1.0 ? 1.0 : progress;
  }

  String _getProgressText(AppProvider provider) {
    final threshold = GradeSystem.getThreshold(provider.currentGrade);
    final remaining = threshold - provider.elapsedSeconds;
    if (remaining <= 0) {
      return '目标达成! 🎉';
    }
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    return '距离目标还有 ${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  bool _celebrationShown = false;

  @override
  void didUpdateWidget(SurfingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset celebration flag when surfing status changes
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (!provider.isSurfing) {
      _celebrationShown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Stack(
      children: [
        // Top Bar (User Profile Bar)
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => const GradeDetailsDialog(),
              );
            },
            child: Container(
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
              child: Row(
                children: [
                  // Avatar (Grade)
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      provider.currentGrade,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.userProfile.nickname.isNotEmpty ? provider.userProfile.nickname : '未设置昵称',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '当前等级: ${provider.currentGrade}',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Theme Switcher (Inside the bar)
                  GestureDetector(
                    onTap: () => _showThemeDialog(context, provider),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.palette, color: Theme.of(context).primaryColor, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Center Content (Button or Timer)
        Center(
          child: provider.isSurfing
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.surfingTimerLabel,
                      style: AppTheme.heading2,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _formatDuration(provider.elapsedSeconds),
                      style: AppTheme.heading1.copyWith(fontSize: 64),
                    ),
                    const SizedBox(height: 20),
                    // Progress bar
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _getProgress(provider),
                              minHeight: 12,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getProgressText(provider),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
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
                      child: Text(
                        provider.currentQuote,
                        style: AppTheme.body.copyWith(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 200,
                      child: CustomButton(
                        text: AppStrings.surfingFinishButton,
                        onPressed: provider.stopSurfing,
                        isLarge: false,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => _showFailDialog(context, provider),
                      child: const Text(
                        '我还是抽了',
                        style: TextStyle(color: Colors.grey, fontSize: 16, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                )
              : const SurfingButton(),
        ),

        // Bottom Content (Smoke Button & Quote)
        if (!provider.isSurfing)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showSmokeDialog(context, provider),
                  child: Text(
                    '记录抽烟',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const RotatingQuoteCard(),
              ],
            ),
          ),
      ],
    );
  }

  void _showSmokeDialog(BuildContext context, AppProvider provider) {
    int selectedMinutesAgo = 0;
    String? selectedReason;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('记录抽烟'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('时间:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _timeOptionButton(
                        context,
                        '当前',
                        selectedMinutesAgo == 0,
                        () => setState(() => selectedMinutesAgo = 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _timeOptionButton(
                        context,
                        '5分钟前',
                        selectedMinutesAgo == 5,
                        () => setState(() => selectedMinutesAgo = 5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('自定义: '),
                    DropdownButton<int>(
                      value: [0, 5].contains(selectedMinutesAgo) ? null : selectedMinutesAgo,
                      hint: const Text('选择'),
                      items: [10, 15, 20, 30, 60].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value分钟前'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() => selectedMinutesAgo = newValue);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('原因 (可选):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppStrings.reasonStress,
                    AppStrings.reasonBoredom,
                    AppStrings.reasonCraving,
                  ].map((reason) {
                    final isSelected = selectedReason == reason;
                    return ChoiceChip(
                      label: Text(reason),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => selectedReason = selected ? reason : null);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () {
                  final timestamp = DateTime.now().subtract(Duration(minutes: selectedMinutesAgo));
                  provider.logSmoke(reason: selectedReason, timestamp: timestamp);
                  Navigator.pop(context);
                },
                child: const Text('确认记录', style: TextStyle(color: AppTheme.primary)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _timeOptionButton(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showFailDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sentiment_dissatisfied,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              const Text(
                '很遗憾这次抵御失败\n请再接再厉',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );

    // Auto-dismiss after 2 seconds and record failure
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pop(context);
        provider.failSurfing('没忍住');
      }
    });
  }

  void _showThemeDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('个性化设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择主题颜色', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(5, (index) {
                final color = AppTheme.getPrimaryColor(index);
                final isSelected = provider.currentThemeIndex == index;
                return GestureDetector(
                  onTap: () {
                    provider.setTheme(index);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.black87, width: 3) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            const Text('选择按钮动画', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _animationOption(context, provider, 0, '呼吸'),
                _animationOption(context, provider, 1, '发光'),
                _animationOption(context, provider, 2, '彩虹'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  Widget _animationOption(BuildContext context, AppProvider provider, int index, String label) {
    final isSelected = provider.currentAnimationMode == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          provider.setAnimationMode(index);
        }
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _showCelebration(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.thumb_up,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                '🎉 恭喜你！',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '成功抵御一次烟瘾\n祝你早日升级',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, height: 1.5),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '继续加油',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
