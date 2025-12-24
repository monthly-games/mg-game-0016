import 'package:flutter/foundation.dart';
import '../../models/level_data.dart';
import '../../models/player_data.dart';
import '../../models/hero.dart';
import '../../features/cards/card_collection.dart';
import '../../data/mock_data.dart';

class CampaignManager extends ChangeNotifier {
  final CardCollection _cardCollection;

  List<Chapter> chapters = [];
  bool isLoading = true;

  CampaignManager(this._cardCollection) {
    _init();
  }

  void _init() {
    _loadMockLevels();
    isLoading = false;
    notifyListeners();
  }

  void _loadMockLevels() {
    // Stage 1
    final stage1 = Stage(
      id: '1-1',
      name: 'Goblin Ambush',
      description: 'A group of goblins blocks the path.',
      enemy: MockData.enemyHero, // Weak goblin
      firstClearReward: const Reward(gold: 50, crystals: 10),
      recommendedPower: 100,
    );

    // Stage 2
    final stage2 = Stage(
      id: '1-2',
      name: 'The Guard Captain',
      description: 'A corrupt captain challenges you.',
      enemy: MockData.enemyHero.copyWith(
        id: 'e2',
        name: 'Captain',
        stats: const HeroStats(hp: 80, maxHp: 80, attack: 7, defense: 2),
      ),
      firstClearReward: const Reward(gold: 100),
      recommendedPower: 150,
    );

    // Stage 3
    final stage3 = Stage(
      id: '1-3',
      name: 'Forest Beast',
      description: 'A wolf howls in the distance.',
      enemy: MockData.enemyHero.copyWith(
        id: 'e3',
        name: 'Wolf',
        stats: const HeroStats(hp: 120, maxHp: 120, attack: 12, defense: 0),
      ),
      firstClearReward: const Reward(gold: 100, crystals: 20),
      recommendedPower: 200,
    );

    chapters = [
      Chapter(
        id: 'c1',
        name: 'Chapter 1: The Beginning',
        stages: [stage1, stage2, stage3],
      ),
    ];
  }

  bool isStageUnlocked(String stageId) {
    // Logic: If stage is in unlocked list
    // Or if previous stage is cleared (simple linear check for now)
    if (_cardCollection.playerData.unlockedStageIds.contains(stageId))
      return true;
    return false;
  }

  void completeStage(Stage stage, bool firstClear) {
    // 1. Give Rewards
    if (firstClear && stage.firstClearReward != null) {
      _grantReward(stage.firstClearReward!);
    } else if (stage.repeatReward != null) {
      _grantReward(stage.repeatReward!);
    }

    // 2. Unlock Next Stage
    _unlockNextStage(stage.id);
  }

  void _grantReward(Reward reward) {
    if (reward.gold > 0) _cardCollection.addGold(reward.gold);
    if (reward.crystals > 0) _cardCollection.addCrystals(reward.crystals);
    // TODO: Cards
  }

  void _unlockNextStage(String currentStageId) {
    // Find current stage idx
    for (var chapter in chapters) {
      int index = chapter.stages.indexWhere((s) => s.id == currentStageId);
      if (index != -1) {
        // Found it. Is there a next stage in this chapter?
        if (index < chapter.stages.length - 1) {
          String nextId = chapter.stages[index + 1].id;
          _cardCollection.unlockStage(nextId);
        } else {
          // End of chapter. Unlock next chapter's first stage?
          // TODO: Cross-chapter logic
        }
        break;
      }
    }
  }
}
