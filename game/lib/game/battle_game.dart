import 'package:flame/game.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '../features/cards/card_data.dart';
import '../features/cards/deck_manager.dart';
import '../features/cards/card_component.dart';
import '../features/battle/enemy_component.dart';
import 'components/floating_text.dart';

import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';

class BattleGame extends FlameGame {
  final DeckManager deckManager;
  final AudioManager _audio = GetIt.I<AudioManager>();

  // Game State
  int currentMana = 3;
  int maxMana = 3;

  BattleGame({required this.deckManager});

  @override
  Color backgroundColor() => AppColors.background;

  // Entities
  late EnemyComponent enemy;

  // Player Stats
  int playerHp = 50;
  int playerBlock = 0;

  @override
  Future<void> onLoad() async {
    try {
      _audio.playBgm('battle_theme.mp3'); // Example BGM
    } catch (e) {
      debugPrint("Audio init failed (expected in tests): $e");
    }

    // Spawn Enemy
    enemy = EnemyComponent(position: Vector2(size.x / 2, size.y / 2 - 100));
    add(enemy);
    enemy.setIntent(10); // Initial Intent

    // Initial Draw
    deckManager.drawCards(5);
    _spawnHand();

    deckManager.addListener(_spawnHand);
  }

  void _spawnHand() {
    // Clear existing cards
    children.whereType<CardComponent>().forEach((c) => c.removeFromParent());

    final hand = deckManager.hand;
    final startX = size.x / 2 - ((hand.length - 1) * 110) / 2;

    for (int i = 0; i < hand.length; i++) {
      add(
        CardComponent(
          data: hand[i],
          onPlay: (component) => _tryPlayCard(component),
          position: Vector2(startX + i * 110, size.y - 100),
        ),
      );
    }
  }

  void _tryPlayCard(CardComponent component) {
    if (component.data.cost > currentMana) {
      print("Not enough mana!");
      return;
    }

    // Pay Cost
    currentMana -= component.data.cost;

    // Apply Effect
    final card = component.data;
    switch (card.type) {
      case CardType.attack:
        enemy.takeDamage(card.value);
        add(
          FloatingTextComponent(
            text: "${card.value}",
            position: enemy.position.clone()..y -= 50,
          ),
        );
        break;
      case CardType.defence:
        playerBlock += card.value;
        add(
          FloatingTextComponent(
            text: "Block +${card.value}",
            position: Vector2(size.x / 2, size.y - 150),
            color: Colors.blueAccent,
          ),
        );
        break;
      case CardType.skill:
        // TODO: Buffs
        break;
    }

    // Discard Logic
    deckManager.playCard(card);
    _audio.playSfx('card_play.wav');
  }

  void endTurn() {
    // 1. Enemy Turn
    int damage = 10; // Fixed enemy damage

    // Apply Block
    if (playerBlock > 0) {
      if (playerBlock >= damage) {
        playerBlock -= damage;
        damage = 0;
      } else {
        damage -= playerBlock;
        playerBlock = 0;
      }
    }

    if (damage > 0) {
      playerHp -= damage;
      add(
        FloatingTextComponent(
          text: "-$damage HP",
          position: Vector2(size.x / 2, size.y - 50),
          color: Colors.redAccent,
        ),
      );
    } else {
      add(
        FloatingTextComponent(
          text: "Blocked!",
          position: Vector2(size.x / 2, size.y - 50),
          color: Colors.grey,
        ),
      );
    }

    print("Enemy dealt $damage damage! Player HP: $playerHp");

    if (playerHp <= 0) {
      print("Game Over");
      add(
        FloatingTextComponent(
          text: "GAME OVER",
          position: Vector2(size.x / 2, size.y / 2),
          color: Colors.red,
          fontSize: 48,
          lifeTime: 3.0,
        ),
      );
      // TODO: Game Over Logic
    }

    // 2. Reset / Draw
    playerBlock = 0;
    currentMana = maxMana;
    deckManager.discardHand();
    deckManager.drawCards(5);

    // Set Next Intent
    enemy.setIntent(damage); // Keep same damage pattern for now
  }
}
