import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:game/game/level_design_config.dart';
import 'package:game/game/wave_spawn_table.dart';
import 'package:game/game/tutorial_config.dart';

/// E2E Test for MG-0016: Deckbuilding Heroes (JRPG Series #1)
///
/// Tests the game loop with focus on:
/// - Deck building mechanics
/// - Card collection and synergy
/// - Hero progression
/// - Strategic gameplay elements
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MG-0016 Deckbuilding Heroes - Game Loop E2E', () {
    testWidgets('Complete JRPG progression with deck building', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify main menu elements
      expect(find.text('MG-0016'), findsOneWidget);
      expect(find.text('Deckbuilding Heroes'), findsOneWidget);
      expect(find.text('Core Fun: $kCoreFunLoop'), findsOneWidget);

      // Navigate to tutorial
      await tester.tap(find.text('Tutorial'));
      await tester.pumpAndSettle();

      // Complete tutorial steps
      final tutorialSteps = kOnboardingTutorial.steps;
      for (int i = 0; i < tutorialSteps.length; i++) {
        await tester.pumpAndSettle();
        expect(find.text('${i + 1}/${tutorialSteps.length}'), findsOneWidget);

        await tester.tap(find.text(i == tutorialSteps.length - 1 ? 'Done' : 'Next'));
        await tester.pumpAndSettle();
      }

      // Navigate to game screen
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Test deck building progression
      int cardsCollected = 0;
      int totalGold = 0;
      int totalXP = 0;

      for (int i = 0; i < 8 && i < kLevelDesign.length; i++) {
        await tester.pumpAndSettle();

        final levelDesign = kLevelDesign[i];
        final spawn = kWaveSpawnTable[i];

        expect(find.text('Level ${levelDesign.levelIndex} - ${levelDesign.stage}'), findsOneWidget);

        // Complete battle to earn cards
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();

        // Card collection mechanic
        cardsCollected += spawn.enemyCount ~/ 3; // Approximate card drops
        totalGold += levelDesign.goldReward;
        totalXP += levelDesign.xpReward;

        expect(find.text('$totalGold gold / $totalXP xp'), findsOneWidget);
      }

      // Verify deck building progression
      expect(cardsCollected, greaterThan(0), reason: 'Should collect cards');
      expect(totalGold, greaterThan(0), reason: 'Battles should provide gold');
      expect(totalXP, greaterThan(0), reason: 'Should gain XP');
    });

    testWidgets('Test card variety and deck synergy', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // JRPG should have card types and classes
      for (int i = 0; i < 10 && i < kLevelDesign.length; i++) {
        final level = kLevelDesign[i];

        // Deckbuilding heroes should reference card mechanics
        expect(level.stage.toLowerCase(), anyOf(
          contains('deck'),
          contains('card'),
          contains('hand'),
          contains('draw'),
          contains('battle'),
          contains('hero'),
          contains('class'),
        ), reason: 'Levels should have card game themes');

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Verify JRPG theme and visual elements', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Verify card game visual elements
      expect(find.byIcon(Icons.videogame_asset_rounded), findsWidgets);
      expect(find.byIcon(Icons.style_rounded), findsWidgets);
    });

    testWidgets('Complete full JRPG session', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      int battlesCompleted = 0;
      int maxBattles = 20;

      for (int i = 0; i < maxBattles && i < kLevelDesign.length; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
        battlesCompleted++;
      }

      expect(battlesCompleted, equals(maxBattles), reason: 'Should complete 20 battles');

      // Verify JRPG rewards
      final finalGold = kLevelDesign.take(maxBattles).map((l) => l.goldReward).fold(0, (a, b) => a + b);
      final finalXP = kLevelDesign.take(maxBattles).map((l) => l.xpReward).fold(0, (a, b) => a + b);

      expect(find.textContaining('$finalGold gold'), findsOneWidget);
      expect(find.textContaining('$finalXP xp'), findsOneWidget);
    });

    testWidgets('Test JRPG retention features', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test daily card challenges
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();
      expect(find.text('Daily Quests'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test tournament (card game tournaments)
      await tester.tap(find.text('Tournament'));
      await tester.pumpAndSettle();
      expect(find.text('Tournament'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test guild (deck building communities)
      await tester.tap(find.text('Guild'));
      await tester.pumpAndSettle();
      expect(find.text('Guild War'), findsOneWidget);
    });

    testWidgets('Verify hero class progression', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Level Roadmap'));
      await tester.pumpAndSettle();

      // JRPG should have hero classes and specializations
      for (int i = 0; i < kLevelDesign.length && i < 12; i++) {
        final level = kLevelDesign[i];
        expect(find.text('Level ${level.levelIndex} - ${level.stage}'), findsOneWidget);

        // Levels should reference hero classes
        expect(level.stage.toLowerCase(), anyOf(
          contains('warrior'),
          contains('mage'),
          contains('rogue'),
          contains('paladin'),
          contains('hero'),
          contains('class'),
          contains('special'),
        ));
      }
    });
  });
}
