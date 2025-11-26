import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../resources/theme.dart';
import '../l10n/app_strings.dart';
import '../widgets/custom_button.dart';
import '../widgets/grade_details_dialog.dart';
import '../widgets/rotating_quote_card.dart';

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
            // Top Bar with Grade and Theme Switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                            '等级: ${provider.currentGrade}',
                            style: AppTheme.heading2.copyWith(color: Theme.of(context).primaryColor, fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  
                  // Theme Switcher Button
                  GestureDetector(
                    onTap: () => _showThemeDialog(context, provider),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.palette, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
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
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
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
              const SizedBox(height: 20),
              // Fail Button (I still smoked)
              TextButton(
                onPressed: () => _showFailDialog(context, provider),
                child: const Text(
                  '我还是抽了',
                  style: TextStyle(color: Colors.grey, fontSize: 16, decoration: TextDecoration.underline),
                ),
              ),
            ],
            
            const Spacer(flex: 2),
            
            // Smoke Button (Redesigned) - Only show when NOT surfing
            if (!provider.isSurfing)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showSmokeDialog(context, provider),
                    icon: const Icon(Icons.smoking_rooms, color: AppTheme.text),
                    label: const Text('记录抽烟', style: TextStyle(color: AppTheme.text, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),

            // Rotating Quote Card (Fixed at bottom)
            const RotatingQuoteCard(),
          ],
        ),
      ),
    );
  }

  void _showSmokeDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录抽烟'), // Hardcoded for now or add to AppStrings
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

  void _showFailDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录抽烟'),
        content: const Text('坚持了这么久，辛苦了。记录一下原因吧？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.failSurfing('没忍住'); // Default reason or add selection logic if needed
              Navigator.pop(context);
            },
            child: const Text('确认记录', style: TextStyle(color: AppTheme.primary)),
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

  void _showThemeDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(5, (index) {
            final color = AppTheme.getPrimaryColor(index);
            final isSelected = provider.currentThemeIndex == index;
            return GestureDetector(
              onTap: () {
                provider.setTheme(index);
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
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
                child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
              ),
            );
          }),
        ),
      ),
    );
  }
}
