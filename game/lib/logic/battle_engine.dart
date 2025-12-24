import 'dart:math';

import '../models/battle_event.dart';
import '../models/battle_state.dart';
import '../models/hero.dart';
import '../models/card.dart';
import '../models/deck.dart';
import 'synergy_engine.dart';

class BattleEngine {
  final Random _rng = Random();

  BattleState initializeBattle({
    required Hero player,
    required Hero enemy,
    required Deck deck,
  }) {
    // Shuffle deck
    List<Card> shuffledDeck = List.from(deck.cards)..shuffle(_rng);

    // Draw initial hand (e.g., 5 cards)
    List<Card> hand = [];
    List<Card> remainingDeck = [];

    if (shuffledDeck.length >= 5) {
      hand = shuffledDeck.sublist(0, 5);
      remainingDeck = shuffledDeck.sublist(5);
    } else {
      hand = List.from(shuffledDeck);
      remainingDeck = [];
    }

    return BattleState(
      player: player,
      enemy: enemy,
      playerDeck: remainingDeck,
      playerHand: hand,
      playerDiscard: const [],
      battleLog: const ["Battle Started!"],
      phase: BattlePhase.playerTurn,
    );
  }

  BattleState nextTurn(BattleState state) {
    if (state.phase == BattlePhase.end) return state;

    List<String> logs = List.from(state.battleLog);
    List<BattleEvent> events = []; // New events for this turn step

    // Auto-progress stages
    if (state.phase == BattlePhase.start) {
      logs.add("Battle Start!");
      return state.copyWith(
        phase: BattlePhase.playerTurn,
        battleLog: logs,
        lastTurnEvents: [],
      );
    }

    Hero player = state.player;
    Hero enemy = state.enemy;
    List<Card> deck = List.from(state.playerDeck);
    List<Card> hand = List.from(state.playerHand);
    List<Card> discard = List.from(state.playerDiscard);

    if (state.phase == BattlePhase.playerTurn) {
      // Draw Logic (simplified: ensure hand has cards)
      if (hand.isEmpty) {
        if (deck.isEmpty) {
          deck = List.from(discard)..shuffle(_rng);
          discard.clear();
          logs.add("Deck reshuffled.");
        }
        // Draw up to 3 cards
        while (hand.length < 3 && deck.isNotEmpty) {
          hand.add(deck.removeLast());
        }
      }

      // Play 1 card (Simple AI: Play first playable)
      // Actually, let's play ALL playable cards for "Auto Battler" feel or just one?
      // Design says "Deck based auto battle".
      // Let's play the First card in hand.
      int cardsPlayedThisTurn = 0;
      if (hand.isNotEmpty) {
        Card card = hand.removeAt(0); // Play top card
        discard.add(card);
        cardsPlayedThisTurn++;
        logs.add("Player uses ${card.name}!");

        // Resolve Effect
        // For now, assuming all are attacks or buffs.
        if (card.type == CardType.attack) {
          int damage = _calculatePlayerDamage(state, card);
          int newHp = max(0, enemy.stats.hp - damage);
          enemy = enemy.copyWith(stats: enemy.stats.copyWith(hp: newHp));
          logs.add("Dealt $damage damage to ${enemy.name}. (HP: $newHp)");

          events.add(
            BattleEvent(
              type: BattleEventType.damage,
              targetId: 'enemy',
              value: damage,
              description: card.name,
            ),
          );
        } else if (card.type == CardType.defense) {
          // Heal or Shield? Let's say Defense adds temporary HP or just heals for now?
          // Or Block?
          // Simple: Heal for now to enable longevity.
          int heal = card.effect.value;
          int newHp = min(player.stats.maxHp, player.stats.hp + heal);
          int healedAmount = newHp - player.stats.hp;
          player = player.copyWith(stats: player.stats.copyWith(hp: newHp));
          logs.add("Player healed for $healedAmount.");

          events.add(
            BattleEvent(
              type: BattleEventType.heal,
              targetId: 'player',
              value: healedAmount,
              description: card.name,
            ),
          );
        }
      }

      return state.copyWith(
        player: player,
        enemy: enemy,
        playerDeck: deck,
        playerHand: hand,
        playerDiscard: discard,
        phase: BattlePhase.enemyTurn, // Pass turn
        battleLog: logs,
        lastTurnEvents: events,
        cardsPlayed: state.cardsPlayed + cardsPlayedThisTurn,
      );
    }

    if (state.phase == BattlePhase.enemyTurn) {
      // Enemy Logic: Simple Attack
      int damage = max(0, enemy.stats.attack - player.stats.defense);
      // Variation?
      int newHp = max(0, player.stats.hp - damage);
      player = player.copyWith(stats: player.stats.copyWith(hp: newHp));
      logs.add("${enemy.name} attacks! Dealt $damage damage. (HP: $newHp)");

      events.add(
        BattleEvent(
          type: BattleEventType.damage,
          targetId: 'player',
          value: damage,
        ),
      );

      BattlePhase nextPhase = BattlePhase.playerTurn;
      if (player.stats.hp <= 0 || enemy.stats.hp <= 0) {
        nextPhase = BattlePhase.end;
        if (player.stats.hp <= 0) {
          logs.add("Defeat...");
        } else {
          logs.add("Victory!");
        }
      }

      return state.copyWith(
        player: player,
        enemy: enemy,
        phase: nextPhase,
        battleLog: logs,
        turnCount: state.turnCount + 1,
        lastTurnEvents: events,
      );
    }

    return state;
  }

  int _calculatePlayerDamage(BattleState state, Card card) {
    if (card.type != CardType.attack) return 0;

    double multiplier = 1.0;

    // Synergy Bonus
    multiplier *= SynergyEngine.calculateEnhancement(
      state.playerDeck,
      card.type,
    );

    // Level Bonus
    // We don't have level in Card model yet?
    // YES we added it in Phase 4 Step 1.
    // 10% bonus per level above 1
    if (card.level > 1) {
      multiplier += (card.level - 1) * 0.10;
    }

    return (card.effect.value * multiplier).round();
  }
}
