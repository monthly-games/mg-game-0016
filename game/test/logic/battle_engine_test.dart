import 'package:flutter_test/flutter_test.dart';
import 'package:game/models/card.dart';
import 'package:game/models/deck.dart';
import 'package:game/models/hero.dart';
import 'package:game/models/battle_state.dart';
import 'package:game/logic/battle_engine.dart';
import 'package:game/data/mock_data.dart';

void main() {
  group('BattleEngine', () {
    late BattleEngine engine;
    late Hero player;
    late Hero enemy;
    late Deck deck;

    setUp(() {
      engine = BattleEngine();
      player = const Hero(
        id: 'p1',
        name: 'Player',
        stats: HeroStats(hp: 100, maxHp: 100, attack: 10, defense: 0),
      );
      enemy = const Hero(
        id: 'e1',
        name: 'Enemy',
        stats: HeroStats(hp: 50, maxHp: 50, attack: 5, defense: 0),
      );
      deck = MockData.starterDeck;
    });

    test('Initializes battle correctly', () {
      final state = engine.initializeBattle(
        player: player,
        enemy: enemy,
        deck: deck,
      );

      expect(state.player.stats.hp, 100);
      expect(state.enemy.stats.hp, 50);
      expect(state.playerHand.length, 5);
      expect(state.playerDeck.length, deck.cards.length - 5);
      expect(state.phase, BattlePhase.playerTurn);
    });

    test('Executes player turn correctly (dealing damage)', () {
      // Setup a state where player has an attack card and can play it
      final attackCard = Card(
        id: 'atk',
        name: 'Big Hit',
        cost: 1,
        rarity: CardRarity.common,
        type: CardType.attack,
        effect: const CardEffect(description: 'Dmg', value: 20),
      );

      var state = engine.initializeBattle(
        player: player,
        enemy: enemy,
        deck: Deck(cards: List.filled(30, attackCard)),
      );

      // Initial HP
      expect(state.enemy.stats.hp, 50);

      // Execute turn
      state = engine.nextTurn(state);

      // Verify Enemy takes damage
      // 5 cards * 20 dmg = 100 dmg -> Enemy should be dead (0 HP)
      expect(state.enemy.stats.hp, 0);
      expect(state.phase, BattlePhase.end);
      expect(state.battleLog.contains("Victory!"), true);
    });

    test('Executes enemy turn correctly', () {
      // Setup state where player attacks do 0 damage (so enemy survives to attack back)
      final weakCard = Card(
        id: 'weak',
        name: 'Weak',
        cost: 1,
        rarity: CardRarity.common,
        type: CardType.attack,
        effect: const CardEffect(description: 'Dmg', value: 0),
      );

      var state = engine.initializeBattle(
        player: player,
        enemy: enemy,
        deck: Deck(cards: List.filled(30, weakCard)),
      );

      // Execute turn
      state = engine.nextTurn(state);

      // Player turn done (0 dmg), Enemy turn done (5 dmg)
      // New turn prepared

      // Enemy attack check
      expect(state.player.stats.hp, 95); // 100 - 5
      expect(state.turnCount, 2);
    });
  });
}
