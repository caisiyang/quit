import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../resources/theme.dart';
import '../l10n/app_strings.dart';
import '../widgets/custom_button.dart';
import '../widgets/grade_details_dialog.dart';

class SurfingTab extends StatefulWidget {
  const SurfingTab({super.key});

  @override
  State<SurfingTab> createState() => _SurfingTabState();
}

class _SurfingTabState extends State<SurfingTab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            // Top Bar with Grade
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => const GradeDetailsDialog(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '当前等级: ${provider.currentGrade}',
                      style: AppTheme.heading2.copyWith(color: AppTheme.primary, fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const Spacer(),
            
            // Main Content
            if (!provider.isSurfing) ...[
              // Idle State
              GestureDetector(
                onTap: provider.startSurfing,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.idleStartButton,
                          style: AppTheme.heading1.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              // Surfing State
              Text(
                AppStrings.surfingTimerLabel,
                style: AppTheme.heading2,
              ),
              const SizedBox(height: 20),
              Text(
                _formatDuration(provider.elapsedSeconds),
                style: AppTheme.heading1.copyWith(fontSize: 64),
              ),
              const SizedBox(height: 40),
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
              CustomButton(
                text: AppStrings.surfingFinishButton,
                onPressed: provider.stopSurfing,
                isLarge: true,
              ),
            ],
            
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
