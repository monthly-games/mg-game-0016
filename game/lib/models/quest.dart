import 'package:equatable/equatable.dart';
import 'level_data.dart';

enum QuestType { playCards, winBattles, earnGold }

class Quest extends Equatable {
  final String id;
  final String description;
  final QuestType type;
  final int targetValue;
  final int currentValue;
  final Reward reward;
  final bool isClaimed;

  const Quest({
    required this.id,
    required this.description,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    required this.reward,
    this.isClaimed = false,
  });

  bool get isCompleted => currentValue >= targetValue;

  Quest copyWith({
    String? id,
    String? description,
    QuestType? type,
    int? targetValue,
    int? currentValue,
    Reward? reward,
    bool? isClaimed,
  }) {
    return Quest(
      id: id ?? this.id,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      reward: reward ?? this.reward,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'type': type.index, // Store enum as index
      'targetValue': targetValue,
      'currentValue': currentValue,
      'reward': reward.toJson(),
      'isClaimed': isClaimed,
    };
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      description: json['description'] as String,
      type: QuestType.values[json['type'] as int],
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int? ?? 0,
      reward: Reward.fromJson(json['reward'] as Map<String, dynamic>),
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    description,
    type,
    targetValue,
    currentValue,
    reward,
    isClaimed,
  ];
}
