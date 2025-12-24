import 'package:equatable/equatable.dart';

enum BattleEventType { damage, heal, buff, debuff }

class BattleEvent extends Equatable {
  final BattleEventType type;
  final String targetId; // 'player' or 'enemy'
  final int value;
  final String description;

  const BattleEvent({
    required this.type,
    required this.targetId,
    required this.value,
    this.description = '',
  });

  @override
  List<Object?> get props => [type, targetId, value, description];
}
