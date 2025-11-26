import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../resources/theme.dart';
import '../l10n/app_strings.dart';
import 'dart:math' as math;

class SurfingButton extends StatefulWidget {
  const SurfingButton({super.key});

  @override
  State<SurfingButton> createState() => _SurfingButtonState();
}

class _SurfingButtonState extends State<SurfingButton> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _scaleAnimation;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  late AnimationController _rainbowController;

  @override
  void initState() {
    super.initState();
    
    // Breathing Animation
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Glow Animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Rainbow Animation
    _rainbowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _glowController.dispose();
    _rainbowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final mode = provider.currentAnimationMode;
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: provider.startSurfing,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathingController, _glowController, _rainbowController]),
        builder: (context, child) {
          BoxDecoration decoration;
          double scale = 1.0;

          if (mode == 0) {
            // Breathing
            scale = _scaleAnimation.value;
            decoration = BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            );
          } else if (mode == 1) {
            // Glow
            decoration = BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.6),
                  blurRadius: 20 + _glowAnimation.value,
                  spreadRadius: 5 + (_glowAnimation.value / 2),
                ),
              ],
            );
          } else {
            // Rainbow (Color Cycle)
            // Use HSL to cycle through hues
            final hue = _rainbowController.value * 360;
            final rainbowColor = HSLColor.fromAHSL(1.0, hue, 0.5, 0.5).toColor(); // Saturation 0.5, Lightness 0.5 for nice colors
            
            // Also add breathing effect to Rainbow mode for consistency? 
            // The user just said "slowly gradient transition", didn't explicitly forbid breathing.
            // But usually "breathing" is a separate mode. Let's keep it simple: just color change.
            // Actually, a static circle changing color might look boring. Let's add the scale animation too.
            scale = _scaleAnimation.value;

            decoration = BoxDecoration(
              color: rainbowColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: rainbowColor.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            );
          }

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 250,
              height: 250,
              decoration: decoration,
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
    );
  }
}
