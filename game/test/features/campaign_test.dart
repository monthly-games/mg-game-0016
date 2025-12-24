import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game/features/cards/card_collection.dart';
import 'package:game/features/campaign/campaign_manager.dart';

void main() {
  group('CampaignManager', () {
    late CardCollection collection;
    late CampaignManager manager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      collection = CardCollection();
      // Wait for collection init? It's async in constructor...
      // Ideally we'd await it. Since we can't, we assume mock works fast enough or
      // we check isLoading.

      manager = CampaignManager(collection);
    });

    test('Initializes with default unlocked stage 1-1', () {
      expect(manager.isStageUnlocked('1-1'), true);
      expect(manager.isStageUnlocked('1-2'), false);
    });

    test('Completing stage 1-1 unlocks 1-2 and gives rewards', () {
      // Mock stage 1
      final stage1 = manager.chapters[0].stages[0];

      // Initial gold
      final initialGold = collection.gold;

      manager.completeStage(stage1, true);

      // Check unlock
      expect(manager.isStageUnlocked('1-2'), true);

      // Check reward
      expect(collection.gold, initialGold + 50);
    });
  });
}
