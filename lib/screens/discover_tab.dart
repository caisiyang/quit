import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../resources/theme.dart';
import '../l10n/app_strings.dart';
import '../widgets/rotating_quote_card.dart';
import '../widgets/user_profile_card.dart';

class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.tabDiscover, style: AppTheme.heading1),
          const SizedBox(height: 20),
          
          // User Profile Card
          const UserProfileCard(),
          const SizedBox(height: 30),
          
          // Did You Know?
          const Text('你知道吗？', style: AppTheme.heading2),
          const SizedBox(height: 10),
          const RotatingQuoteCard(),
          
          const SizedBox(height: 30),
          
          // Urge Surfing Principle Card
          const Text('关于冲动冲浪', style: AppTheme.heading2),
          const SizedBox(height: 10),
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '烟瘾就像海浪',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                const SizedBox(height: 10),
                const Text(
                  '科学研究表明，每次烟瘾来袭时的强烈渴望通常只会持续 5 到 10 分钟。就像海浪一样，它会高涨，达到顶峰，但最终一定会消退。\n\n你不需要痛苦地对抗它，只需要像冲浪者一样，观察它，感受它，等待它自然过去。',
                  style: AppTheme.body,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb, color: AppTheme.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '每一次的成功抵御，都是对大脑奖赏回路的一次重塑。坚持下去，你正在一步步夺回对自己生活的掌控权！',
                          style: TextStyle(fontSize: 14, color: AppTheme.text, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
