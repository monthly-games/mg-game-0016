import 'package:equatable/equatable.dart';
import 'hero.dart';

class Reward extends Equatable {
  final int gold;
  final int crystals;
  final List<String>? cardIds; // IDs of cards to grant

  const Reward({this.gold = 0, this.crystals = 0, this.cardIds});

  @override
  List<Object?> get props => [gold, crystals, cardIds];

  Map<String, dynamic> toJson() {
    return {'gold': gold, 'crystals': crystals, 'cardIds': cardIds};
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      gold: json['gold'] as int? ?? 0,
      crystals: json['crystals'] as int? ?? 0,
      cardIds: (json['cardIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

class Stage extends Equatable {
  final String id;
  final String name;
  final String description;
  final Hero enemy; // The enemy to fight
  final Reward? firstClearReward;
  final Reward? repeatReward;
  final int recommendedPower;

  const Stage({
    required this.id,
    required this.name,
    required this.description,
    required this.enemy,
    this.firstClearReward,
    this.repeatReward,
    this.recommendedPower = 0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    enemy,
    firstClearReward,
    repeatReward,
    recommendedPower,
  ];
}

class Chapter extends Equatable {
  final String id;
  final String name;
  final List<Stage> stages;

  const Chapter({required this.id, required this.name, required this.stages});

  @override
  List<Object?> get props => [id, name, stages];
}
