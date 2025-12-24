import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game/features/cards/card_collection.dart';
import 'package:game/data/mock_data.dart';
import 'package:game/models/card.dart';

void main() {
  group('Phase 4 features', () {
    late CardCollection collection;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      collection = CardCollection();
      // await collection init if possible, or assume mock sync
    });

    test('Card Upgrades work', () async {
      // Mock gold
      // Accessing private gold via getter
      // Need way to set gold or just assume start 100

      // Add card to collection
      collection.openCardPack(packSize: 1);
      // We don't know what we got, but let's assume we can unlock 'strike'.
      // MockData.strike is in DB.
      // Let's force add a card if possible or just use a known one.
      // The collection initializes with starter deck (Strikes).

      String cardId = MockData.strike.id;

      // Helper to check level
      expect(collection.getCardLevel(cardId), 1);

      // Ensure specific gold amount
      collection.addGold(1000);

      // Upgrade
      collection.upgradeCard(cardId);

      expect(collection.getCardLevel(cardId), 2);
    });

    test('New cards are registered', () {
      expect(collection.getCardById('c4'), isNotNull); // Quick Slash
      expect(collection.getCardById('c7'), isNotNull); // Meteor
    });
  });
}
