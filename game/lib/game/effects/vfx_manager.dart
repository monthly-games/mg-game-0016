import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// VFX Manager for Deckbuilding Heroes (MG-0016)
/// Card Game + Auto-Battler + JRPG 게임 전용 이펙트 관리자
class VfxManager extends Component with HasGameRef {
  VfxManager();
  final Random _random = Random();

  // Card Effects
  void showCardDraw(Vector2 position) {
    gameRef.add(_createSparkleEffect(position: position, color: Colors.white, count: 10));
    gameRef.add(_createBurstEffect(position: position, color: Colors.lightBlue.shade200, count: 8, speed: 50, lifespan: 0.4));
  }

  void showCardPlay(Vector2 position, Color cardColor) {
    gameRef.add(_createExplosionEffect(position: position, color: cardColor, count: 20, radius: 50));
    gameRef.add(_createGroundCircle(position: position, color: cardColor));
  }

  void showCardUpgrade(Vector2 position) {
    gameRef.add(_createExplosionEffect(position: position, color: Colors.amber, count: 25, radius: 55));
    gameRef.add(_createSparkleEffect(position: position, color: Colors.yellow, count: 15));
    gameRef.add(_UpgradeText(position: position));
  }

  void showDeckShuffle(Vector2 position) {
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 60), () {
        if (!isMounted) return;
        gameRef.add(_createSparkleEffect(position: position + Vector2((_random.nextDouble() - 0.5) * 50, (_random.nextDouble() - 0.5) * 30), color: Colors.white, count: 5));
      });
    }
  }

  // Battle Effects
  void showAttackHit(Vector2 position, {Color color = Colors.white, bool isCritical = false}) {
    gameRef.add(_createHitEffect(position: position, color: color, isCritical: isCritical));
    if (isCritical) gameRef.add(_createSparkleEffect(position: position, color: Colors.yellow, count: 12));
  }

  void showDamageNumber(Vector2 position, int damage, {bool isCritical = false}) {
    gameRef.add(_DamageNumber(position: position, damage: damage, isCritical: isCritical));
  }

  void showSkillActivation(Vector2 position, Color skillColor) {
    gameRef.add(_createConvergeEffect(position: position, color: skillColor));
    gameRef.add(_createGroundCircle(position: position, color: skillColor));
  }

  void showUnitDeath(Vector2 position) {
    gameRef.add(_createExplosionEffect(position: position, color: Colors.red, count: 18, radius: 45));
    gameRef.add(_createSmokeEffect(position: position, count: 5));
  }

  // Story/Chapter Effects
  void showChapterComplete(Vector2 position) {
    gameRef.add(_createExplosionEffect(position: position, color: Colors.amber, count: 35, radius: 70));
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (!isMounted) return;
        gameRef.add(_createSparkleEffect(position: position + Vector2((_random.nextDouble() - 0.5) * 80, (_random.nextDouble() - 0.5) * 60), color: Colors.yellow, count: 8));
      });
    }
    gameRef.add(_ChapterText(position: position));
  }

  void showRewardClaim(Vector2 position) {
    gameRef.add(_createCoinEffect(position: position, count: 12));
    gameRef.add(_createSparkleEffect(position: position, color: Colors.amber, count: 10));
  }

  void showNumberPopup(Vector2 position, String text, {Color color = Colors.white}) {
    gameRef.add(_NumberPopup(position: position, text: text, color: color));
  }

  // Private generators
  ParticleSystemComponent _createBurstEffect({required Vector2 position, required Color color, required int count, required double speed, required double lifespan}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: lifespan, generator: (i) {
      final angle = (i / count) * 2 * pi;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * (speed * (0.5 + _random.nextDouble() * 0.5)), acceleration: Vector2(0, 130), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 4 * (1.0 - particle.progress * 0.5), Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createHitEffect({required Vector2 position, required Color color, required bool isCritical}) {
    final count = isCritical ? 18 : 10; final speed = isCritical ? 130.0 : 90.0;
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.4, generator: (i) {
      final angle = (i / count) * 2 * pi;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * (speed * (0.5 + _random.nextDouble() * 0.5)), acceleration: Vector2(0, 180), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, (isCritical ? 5 : 3) * (1.0 - particle.progress * 0.5), Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createExplosionEffect({required Vector2 position, required Color color, required int count, required double radius}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.7, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi; final speed = radius * (0.4 + _random.nextDouble() * 0.6);
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 90), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 5 * (1.0 - particle.progress * 0.3), Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createConvergeEffect({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 12, lifespan: 0.5, generator: (i) {
      final startAngle = (i / 12) * 2 * pi; final startPos = Vector2(cos(startAngle), sin(startAngle)) * 45;
      return MovingParticle(from: position + startPos, to: position.clone(), child: ComputedParticle(renderer: (canvas, particle) {
        canvas.drawCircle(Offset.zero, 4, Paint()..color = color.withOpacity((1.0 - particle.progress * 0.5).clamp(0.0, 1.0)));
      }));
    }));
  }

  ParticleSystemComponent _createSparkleEffect({required Vector2 position, required Color color, required int count}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.5, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi; final speed = 45 + _random.nextDouble() * 35;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 35), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0); final size = 3 * (1.0 - particle.progress * 0.5);
        final path = Path(); for (int j = 0; j < 4; j++) { final a = (j * pi / 2); if (j == 0) path.moveTo(cos(a) * size, sin(a) * size); else path.lineTo(cos(a) * size, sin(a) * size); } path.close();
        canvas.drawPath(path, Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createSmokeEffect({required Vector2 position, required int count}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.7, generator: (i) {
      return AcceleratedParticle(position: position.clone() + Vector2((_random.nextDouble() - 0.5) * 20, 0), speed: Vector2((_random.nextDouble() - 0.5) * 12, -25 - _random.nextDouble() * 15), acceleration: Vector2(0, -8), child: ComputedParticle(renderer: (canvas, particle) {
        final progress = particle.progress; final opacity = (0.4 - progress * 0.4).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 5 + progress * 8, Paint()..color = Colors.grey.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createGroundCircle({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 1, lifespan: 0.6, generator: (i) {
      return ComputedParticle(renderer: (canvas, particle) {
        final progress = particle.progress; final opacity = (1.0 - progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset(position.x, position.y), 15 + progress * 30, Paint()..color = color.withOpacity(opacity * 0.4)..style = PaintingStyle.stroke..strokeWidth = 2);
      });
    }));
  }

  ParticleSystemComponent _createCoinEffect({required Vector2 position, required int count}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.7, generator: (i) {
      final angle = -pi / 2 + (_random.nextDouble() - 0.5) * pi / 4; final speed = 120 + _random.nextDouble() * 70;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 320), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress * 0.2).clamp(0.0, 1.0);
        canvas.save(); canvas.rotate(particle.progress * 3 * pi);
        canvas.drawOval(const Rect.fromLTWH(-3, -2, 6, 4), Paint()..color = Colors.amber.withOpacity(opacity));
        canvas.restore();
      }));
    }));
  }
}

class _DamageNumber extends TextComponent {
  _DamageNumber({required Vector2 position, required int damage, required bool isCritical}) : super(text: '$damage', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: isCritical ? 24 : 16, fontWeight: FontWeight.bold, color: isCritical ? Colors.yellow : Colors.white, shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))])));
  @override Future<void> onLoad() async { await super.onLoad(); add(MoveByEffect(Vector2(0, -40), EffectController(duration: 0.7, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 0.7, startDelay: 0.2))); add(RemoveEffect(delay: 0.9)); }
}

class _UpgradeText extends TextComponent {
  _UpgradeText({required Vector2 position}) : super(text: 'UPGRADE!', position: position + Vector2(0, -35), anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber, shadows: [Shadow(color: Colors.orange, blurRadius: 8)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.5); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3, curve: Curves.elasticOut))); add(MoveByEffect(Vector2(0, -20), EffectController(duration: 1.0, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.0, startDelay: 0.5))); add(RemoveEffect(delay: 1.5)); }
}

class _ChapterText extends TextComponent {
  _ChapterText({required Vector2 position}) : super(text: 'CHAPTER CLEAR!', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2, shadows: [Shadow(color: Colors.orange, blurRadius: 12)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.3); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.4, curve: Curves.elasticOut))); add(RemoveEffect(delay: 2.5)); }
}

class _NumberPopup extends TextComponent {
  _NumberPopup({required Vector2 position, required String text, required Color color}) : super(text: text, position: position, anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))])));
  @override Future<void> onLoad() async { await super.onLoad(); add(MoveByEffect(Vector2(0, -25), EffectController(duration: 0.6, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 0.6, startDelay: 0.2))); add(RemoveEffect(delay: 0.8)); }
}
