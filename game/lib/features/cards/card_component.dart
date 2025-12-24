import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'card_data.dart';

class CardComponent extends PositionComponent with DragCallbacks, HasGameRef {
  final CardData data;
  final Function(CardComponent) onPlay; // Callback when dropped to play

  Vector2 _dragOffset = Vector2.zero();
  Vector2 _originalPosition = Vector2.zero();
  bool _isDragging = false;
  Sprite? _frameSprite;

  CardComponent({
    required this.data,
    required this.onPlay,
    required Vector2 position,
  }) : super(
         position: position,
         size: Vector2(140, 210), // Adjusted for frame aspect ratio
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    _originalPosition = position.clone();

    String frameName;
    switch (data.type) {
      case CardType.attack:
        frameName = 'cards/card_frame_attack.png';
        break;
      case CardType.defence:
        frameName = 'cards/card_frame_defence.png';
        break;
      case CardType.skill:
        frameName = 'cards/card_frame_skill.png';
        break;
    }

    try {
      _frameSprite = await gameRef.loadSprite(frameName);
    } catch (e) {
      print('Failed to load card frame $frameName: $e');
    }
  }

  @override
  void render(Canvas canvas) {
    // Tether Line
    if (_isDragging) {
      final localOrigin = _originalPosition - position + size / 2;
      canvas.drawLine(
        (size / 2).toOffset(),
        localOrigin.toOffset(),
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Selection/Drag Highlight
    if (_isDragging) {
      canvas.drawRect(
        size.toRect().inflate(5),
        Paint()..color = Colors.cyanAccent.withOpacity(0.5),
      );
    }

    if (_frameSprite != null) {
      _frameSprite!.render(canvas, size: size);
    } else {
      // Fallback
      // Card Base
      final paint = Paint()..color = _getCardColor(data.type);
      final rrect = RRect.fromRectAndRadius(
        size.toRect(),
        const Radius.circular(12),
      );
      canvas.drawRRect(rrect, paint);

      // Border
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white
          ..strokeWidth = 2,
      );
    }

    // Cost (Top Left)
    final textPaint = TextPaint(
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
    textPaint.render(canvas, "${data.cost}", Vector2(10, 10));

    // Name (Center)
    TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ).render(
      canvas,
      data.name,
      Vector2(width / 2, 40),
      anchor: Anchor.topCenter,
    );

    // Value (Center Large)
    TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    ).render(
      canvas,
      "${data.value}",
      Vector2(width / 2, height / 2),
      anchor: Anchor.center,
    );

    // Description (Bottom)
    // Simplified text wrap... providing truncated for now
    TextPaint(
      style: const TextStyle(color: Colors.white70, fontSize: 10),
    ).render(canvas, data.description, Vector2(10, height - 40));
  }

  Color _getCardColor(CardType type) {
    switch (type) {
      case CardType.attack:
        return Colors.red[700]!;
      case CardType.defence:
        return Colors.blue[700]!;
      case CardType.skill:
        return Colors.green[700]!;
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    _isDragging = true;
    _dragOffset = event.localPosition;
    priority = 100; // Bring to front
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _isDragging = false;
    priority = 0;

    // Check play condition (e.g., dragged high enough)
    if (position.y < _originalPosition.y - 100) {
      onPlay(this);
    } else {
      // Return to hand
      position = _originalPosition.clone();
    }
    super.onDragEnd(event);
  }
}
