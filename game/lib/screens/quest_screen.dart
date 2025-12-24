import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/meta/quest_manager.dart';
import '../models/quest.dart';

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
      appBar: AppBar(title: const Text('Daily Quests')),
      body: Consumer<QuestManager>(
        builder: (context, questManager, child) {
          final quests = questManager.activeQuests;

          if (quests.isEmpty) {
            return const Center(child: Text("No active quests"));
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quest.description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (quest.currentValue / quest.targetValue).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[800],
              color: isCompleted ? Colors.green : Colors.blue,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${quest.currentValue} / ${quest.targetValue}"),
                if (isClaimed)
                  const Text("Claimed", style: TextStyle(color: Colors.green))
                else if (isCompleted)
                  ElevatedButton(
                    onPressed: () => manager.claimReward(quest.id),
                    child: const Text("Claim Reward"),
                  )
                else
                  Text("Reward: ${quest.reward.gold} Gold"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
