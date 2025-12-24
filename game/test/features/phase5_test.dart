import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game/features/cards/card_collection.dart';
import 'package:game/features/meta/quest_manager.dart';
import 'package:game/models/quest.dart';
import 'package:game/models/level_data.dart';

void main() {
  group('Phase 5 - Quest System', () {
    late CardCollection collection;
    late QuestManager questManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      collection = CardCollection();
      // Force empty initial quests
      collection.updatePlayerDataExternal(
        collection.playerData.copyWith(activeQuests: []),
      );
      questManager = QuestManager(collection);
    });

    test('Generates 3 initial quests', () {
      questManager.checkDailyQuests();
      expect(questManager.activeQuests.length, 3);
      expect(collection.playerData.activeQuests.length, 3);
    });

    test('Updates progress correctly', () {
      // Add a specific quest manually to test deterministically
      const testQuest = Quest(
        id: 'test1',
        description: 'Test Win',
        type: QuestType.winBattles,
        targetValue: 5,
        reward: Reward(gold: 10),
      );

      collection.updatePlayerDataExternal(
        collection.playerData.copyWith(activeQuests: [testQuest]),
      );

      questManager.updateProgress(QuestType.winBattles, 1);

      expect(questManager.activeQuests.first.currentValue, 1);

      questManager.updateProgress(QuestType.winBattles, 4);
      expect(questManager.activeQuests.first.currentValue, 5);
      expect(questManager.activeQuests.first.isCompleted, true);
    });

    test('Claims reward', () {
      const testQuest = Quest(
        id: 'test2',
        description: 'Test Claim',
        type: QuestType.winBattles,
        targetValue: 1,
        currentValue: 1,
        reward: Reward(gold: 100),
      );

      collection.updatePlayerDataExternal(
        collection.playerData.copyWith(gold: 0, activeQuests: [testQuest]),
      );

      questManager.claimReward('test2');

      expect(collection.playerData.gold, 100);
      expect(collection.playerData.activeQuests.first.isClaimed, true);
    });
  });
}
