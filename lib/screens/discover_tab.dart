import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../resources/theme.dart';
import '../l10n/app_strings.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  String? _currentFact;
  String? _currentQuote;

  @override
  void initState() {
    super.initState();
    // Initial load will happen when provider notifies, or we can trigger it.
    // But since provider loads async, we might need to wait or listen.
    // For simplicity, we'll rely on build to pick one if null.
  }

  void _refreshFact(List<String> facts) {
    if (facts.isEmpty) return;
    setState(() {
      _currentFact = facts[Random().nextInt(facts.length)];
    });
  }

  void _refreshQuote(List<String> quotes) {
    if (quotes.isEmpty) return;
    setState(() {
      _currentQuote = quotes[Random().nextInt(quotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Initialize if null and data available
    if (_currentFact == null && provider.facts.isNotEmpty) {
      _currentFact = provider.facts[Random().nextInt(provider.facts.length)];
    }
    if (_currentQuote == null && provider.quotes.isNotEmpty) {
      _currentQuote = provider.quotes[Random().nextInt(provider.quotes.length)];
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.padding),
      child: Column(
        children: [
          _buildCard(
            title: AppStrings.factCardTitle,
            content: _currentFact ?? 'Loading...',
            onRefresh: () => _refreshFact(provider.facts),
          ),
          const SizedBox(height: 20),
          _buildCard(
            title: AppStrings.quoteCardTitle,
            content: _currentQuote ?? 'Loading...',
            onRefresh: () => _refreshQuote(provider.quotes),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required String content, required VoidCallback onRefresh}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTheme.heading2),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppTheme.primary),
                  onPressed: onRefresh,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              content,
              style: AppTheme.body.copyWith(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
