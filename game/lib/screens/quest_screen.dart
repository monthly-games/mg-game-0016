import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/meta/quest_manager.dart';
import '../models/quest.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';import 'package:mg_common_game/l10n/localization.dart';


class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh quests on enter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestManager>().checkDailyQuests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('quest_daily_quests_2'.tr)),
      body: Consumer<QuestManager>(
        builder: (context, questManager, child) {
          final quests = questManager.activeQuests;

          if (quests.isEmpty) {
            return Center(child: Text('quest_no_active_quests'.tr));
          }

          return ListView.builder(
            itemCount: quests.length,
            itemBuilder: (context, index) {
              final quest = quests[index];
              return _buildQuestItem(context, quest, questManager);
            },
          );
        },
      ),
    );
  }

  Widget _buildQuestItem(
    BuildContext context,
    Quest quest,
    QuestManager manager,
  ) {
    bool isCompleted = quest.isCompleted;
    bool isClaimed = quest.isClaimed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isClaimed ? Colors.white12 : Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(MGSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quest.description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: MGSpacing.xs),
            LinearProgressIndicator(
              value: (quest.currentValue / quest.targetValue).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[800],
              color: isCompleted ? MGColors.success : MGColors.info,
            ),
            const SizedBox(height: MGSpacing.xxs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('quest_questcurrentvalue_questtargetvalue'.tr),
                if (isClaimed)
                  const Text("Claimed", style: TextStyle(color: MGColors.success))
                else if (isCompleted)
                  ElevatedButton(
                    onPressed: () => manager.claimReward(quest.id),
                    child: Text('notification_claim_reward'.tr),
                  )
                else
                  Text('quest_reward_questrewardgold_gold'.tr),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
