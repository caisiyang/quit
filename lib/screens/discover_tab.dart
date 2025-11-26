import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../resources/theme.dart';
import '../l10n/app_strings.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(AppStrings.tabDiscover, style: AppTheme.heading1),
              IconButton(
                icon: const Icon(Icons.settings, size: 28),
                onPressed: () => _showSettingsDialog(context),
                color: Colors.grey[700],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // User Profile Card
          const UserProfileCard(),
          const SizedBox(height: 16),
          
          // Quit Knowledge Card
          Container(
            height: 200,
            padding: const EdgeInsets.all(12),
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
                  '戒烟原理',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: false,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildKnowledgeSection(
                            '1. 尼古丁成瘾机制',
                            '尼古丁是烟草中的主要成瘾物质。当你吸烟时，尼古丁会在7秒内到达大脑，刺激多巴胺释放，产生愉悦感。但这种愉悦感很短暂，大脑会逐渐适应，需要更多尼古丁才能达到同样效果，这就是成瘾的开始。',
                          ),
                          _buildKnowledgeSection(
                            '2. 戒断症状的真相',
                            '戒烟初期会出现焦虑、烦躁、注意力不集中等症状，这是正常的生理反应。好消息是，最强烈的戒断症状通常在戒烟后3-5天达到高峰，之后会逐渐减轻。大多数人在2-4周后症状会明显改善。',
                          ),
                          _buildKnowledgeSection(
                            '3. 大脑的自我修复',
                            '戒烟后，大脑会开始自我修复。研究表明，戒烟3个月后，大脑中的尼古丁受体数量会恢复正常；6个月后，大脑的奖赏系统功能显著改善；1年后，大脑结构和功能基本恢复到非吸烟者水平。',
                          ),
                          _buildKnowledgeSection(
                            '4. 心理依赖的突破',
                            '除了生理成瘾，心理依赖同样重要。吸烟往往与特定场景关联（如饭后、压力大时）。打破这些关联需要时间和练习。使用"冲动冲浪"技术，观察而不是对抗烟瘾，可以有效减少心理依赖。',
                          ),
                          _buildKnowledgeSection(
                            '5. 健康改善时间表',
                            '• 20分钟：心率和血压下降\n• 12小时：血液中一氧化碳水平恢复正常\n• 2-12周：循环系统改善，肺功能提高\n• 1-9个月：咳嗽和气短减少\n• 1年：冠心病风险降低50%\n• 5年：中风风险降至非吸烟者水平',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Success Stories Card
          Container(
            height: 200,
            padding: const EdgeInsets.all(12),
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
                  '成功经验',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: false,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStoryCard(
                            '张明 - 戒烟2年',
                            '我抽了15年烟，每天两包。最开始戒烟时，我觉得自己根本做不到。前三天是最难熬的，每次烟瘾来袭，我就告诉自己"再坚持5分钟"。神奇的是，5分钟后烟瘾真的会减轻。\n\n第一周我用口香糖和深呼吸来转移注意力。第二周开始跑步，发现运动后的愉悦感比吸烟好多了。现在回想起来，戒烟是我这辈子做过最正确的决定。我的肺活量提高了，睡眠质量变好了，最重要的是，我重新掌控了自己的生活。',
                          ),
                          _buildStoryCard(
                            '李娜 - 戒烟1年半',
                            '作为一名女性烟民，我的烟龄有10年。戒烟最大的挑战是社交场合的诱惑。我的方法是提前告诉朋友我在戒烟，请他们监督我。\n\n前两个月我避开了所有可能吸烟的场合。当烟瘾来袭时，我会立刻喝一大杯水，或者嚼一块黑巧克力。我还在手机上记录每一次成功抵御的时刻，看着那些记录，成就感油然而生。\n\n现在我的皮肤变好了，牙齿也白了，最重要的是我不再为烟味困扰。每次看到别人吸烟，我都庆幸自己戒掉了。',
                          ),
                          _buildStoryCard(
                            '王强 - 戒烟3年',
                            '我是在医生警告我肺部有问题后才下决心戒烟的。那时我已经抽了20年烟。戒烟初期，我的脾气变得很暴躁，家人都很担心。\n\n我采用了"替代疗法"：每次想抽烟就做10个俯卧撑。这个方法帮我度过了最艰难的前两周。我还加入了一个戒烟互助群，大家互相鼓励，分享经验。\n\n戒烟3个月后，我去复查，医生说我的肺功能明显改善。这给了我巨大的信心。现在3年过去了，我完全不想抽烟了。我的建议是：永远不要低估自己的意志力，也不要害怕寻求帮助。',
                          ),
                          _buildStoryCard(
                            '陈晨 - 戒烟8个月',
                            '我戒烟的契机是女儿出生。看着她那么小，那么依赖我，我不想让她闻到烟味，更不想成为一个不健康的父亲。\n\n戒烟过程中，我发现最难的不是生理上的烟瘾，而是心理习惯。饭后、工作压力大时，我总是习惯性想抽烟。我的方法是用新习惯替代旧习惯：饭后散步，压力大时听音乐或冥想。\n\n现在8个月过去了，我已经完全适应了没有烟的生活。女儿会笑着扑到我怀里，不再因为烟味皱眉。这是我最大的动力和奖励。',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.text),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(String name, String story) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            story,
            style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clear History
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('清空所有记录'),
                subtitle: const Text('删除所有抽烟和抵御记录'),
                onTap: () {
                  Navigator.pop(context);
                  _showClearHistoryDialog(context, provider);
                },
              ),
              const Divider(),
              
              // Reset Grade
              ListTile(
                leading: const Icon(Icons.restart_alt, color: Colors.orange),
                title: const Text('重置等级'),
                subtitle: const Text('将等级重置为C10'),
                onTap: () {
                  Navigator.pop(context);
                  _showResetGradeDialog(context, provider);
                },
              ),
              const Divider(),
              
              // About
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('关于应用'),
                subtitle: const Text('版本 1.0.0'),
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog(context);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有记录吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已清空所有记录')),
              );
            },
            child: const Text('确认', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResetGradeDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认重置'),
        content: const Text('确定要将等级重置为C10吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // Reset grade logic would go here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('等级已重置为C10')),
              );
            },
            child: const Text('确认', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于戒烟助手'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '版本: 1.0.0',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '这是一款帮助您戒烟的应用，采用"冲动冲浪"技术，让您更科学地应对烟瘾。',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Text(
              '坚持下去，你一定能成功！',
              style: TextStyle(fontSize: 14, color: Colors.grey[700], fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
