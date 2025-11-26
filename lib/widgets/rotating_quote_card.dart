import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../resources/theme.dart';

class RotatingQuoteCard extends StatefulWidget {
  const RotatingQuoteCard({super.key});

  @override
  State<RotatingQuoteCard> createState() => _RotatingQuoteCardState();
}

class _RotatingQuoteCardState extends State<RotatingQuoteCard> {
  Timer? _timer;
  String _currentText = "坚持就是胜利";
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Schedule the first update after the widget is built and provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateText();
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateText();
    });
  }

  void _updateText() {
    if (!mounted) return;
    final provider = Provider.of<AppProvider>(context, listen: false);
    final allTexts = [...provider.quotes, ...provider.facts];
    
    if (allTexts.isNotEmpty) {
      setState(() {
        _currentText = allTexts[_random.nextInt(allTexts.length)];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Text(
          _currentText,
          key: ValueKey<String>(_currentText),
          style: AppTheme.body.copyWith(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: AppTheme.text.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
