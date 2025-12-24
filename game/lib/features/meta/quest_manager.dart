import 'dart:math';

import 'package:flutter/foundation.dart';
import '../../models/player_data.dart';
import '../../models/quest.dart';
import '../../features/cards/card_collection.dart';
import '../../models/level_data.dart'; // For Reward

class QuestManager extends ChangeNotifier {
  final CardCollection _cardCollection;
  final Random _rng = Random();

  QuestManager(this._cardCollection);

  // Helper to get current active quests
  List<Quest> get activeQuests => _cardCollection.playerData.activeQuests;

  // Generate daily quests if needed
  void checkDailyQuests() {
    // Ideally check date, for now just ensure we have 3 quests.
    if (activeQuests.length < 3) {
      int needed = 3 - activeQuests.length;
      List<Quest> newQuests = [];
      for (int i = 0; i < needed; i++) {
        newQuests.add(_generateRandomQuest());
      }

      // Update player data
      final newData = _cardCollection.playerData.copyWith(
        activeQuests: [...activeQuests, ...newQuests],
      );
      _cardCollection.updatePlayerDataExternal(newData);
    }
  }

  Quest _generateRandomQuest() {
    // Simple pool
    int typeIndex = _rng.nextInt(3);
    String id =
        DateTime.now().millisecondsSinceEpoch.toString() +
        _rng.nextInt(1000).toString();

    if (typeIndex == 0) {
      return Quest(
        id: id,
        description: "Win 3 Battles",
        type: QuestType.winBattles,
        targetValue: 3,
        reward: const Reward(gold: 50),
      );
    } else if (typeIndex == 1) {
      return Quest(
        id: id,
        description: "Play 20 Cards",
        type: QuestType.playCards,
        targetValue: 20,
        reward: const Reward(gold: 30),
      );
    } else {
      return Quest(
        id: id,
        description: "Earn 100 Gold",
        type: QuestType.earnGold,
        targetValue: 100,
        reward: const Reward(crystals: 5),
      );
    }
  }

  void updateProgress(QuestType type, int amount) {
    if (activeQuests.isEmpty) return;

    List<Quest> updatedQuests = [];
    bool changed = false;

    for (var quest in activeQuests) {
      if (!quest.isCompleted && !quest.isClaimed && quest.type == type) {
        int newValue = quest.currentValue + amount;
        updatedQuests.add(quest.copyWith(currentValue: newValue));
        changed = true;
      } else {
        updatedQuests.add(quest);
      }
    }

    if (changed) {
      final newData = _cardCollection.playerData.copyWith(
        activeQuests: updatedQuests,
      );
      _cardCollection.updatePlayerDataExternal(newData);
    }
  }

  void claimReward(String questId) {
    int index = activeQuests.indexWhere((q) => q.id == questId);
    if (index == -1) return;

    Quest quest = activeQuests[index];
    if (quest.isCompleted && !quest.isClaimed) {
      // Grant reward
      _cardCollection.addGold(quest.reward.gold);
      _cardCollection.addCrystals(quest.reward.crystals);
      // Cards? Not implementing card rewards from quests yet for simplicity, but logic exists.

      // Mark claimed
      List<Quest> updatedQuests = List.from(activeQuests);
      updatedQuests[index] = quest.copyWith(isClaimed: true);

      final newData = _cardCollection.playerData.copyWith(
        activeQuests: updatedQuests,
      );
      _cardCollection.updatePlayerDataExternal(newData);
    }
  }
}
