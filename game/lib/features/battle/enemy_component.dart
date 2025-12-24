import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EnemyComponent extends PositionComponent with HasGameRef {
  double maxHp = 50;
  double currentHp = 50;

  // Visual
  late TextComponent hpText;
  late TextComponent intentText;
  Sprite? _sprite;

  int _nextDamage = 0;

  EnemyComponent({required Vector2 position})
    : super(position: position, size: Vector2(250, 250), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    hpText = TextComponent(
      text: "HP: ${currentHp.toInt()}",
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(width / 2, -30),
      anchor: Anchor.center,
    );
    add(hpText);

    intentText = TextComponent(
      text: "",
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.yellowAccent, fontSize: 16),
      ),
      position: Vector2(width / 2, -60),
      anchor: Anchor.center,
    );
    add(intentText);

    try {
      _sprite = await gameRef.loadSprite('enemy_boss.png');
    } catch (e) {
      print('Failed to load enemy sprite: $e');
    }
  }

  void setIntent(int damage) {
    _nextDamage = damage;
    intentText.text = "Intent: Attack $_nextDamage";
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      _sprite!.render(canvas, size: size);
    } else {
      // Body
      canvas.drawCircle(
        Offset(width / 2, height / 2),
        width / 2,
        Paint()..color = Colors.red[800]!,
      );

      // Eyes
      canvas.drawCircle(Offset(30, 40), 10, Paint()..color = Colors.yellow);
      canvas.drawCircle(Offset(70, 40), 10, Paint()..color = Colors.yellow);
    }
  }

  void takeDamage(int amount) {
    currentHp -= amount;
    if (currentHp < 0) currentHp = 0;
    hpText.text = "HP: ${currentHp.toInt()}";

    // Visual Flash
    // TODO: Add flash effect
  }

  void attack() {
    // Visual Shake
  }
}
