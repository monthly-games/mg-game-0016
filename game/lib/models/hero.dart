import 'package:equatable/equatable.dart';

class HeroStats extends Equatable {
  final int hp;
  final int maxHp;
  final int attack;
  final int defense;

  const HeroStats({
    required this.hp,
    required this.maxHp,
    required this.attack,
    required this.defense,
  });

  HeroStats copyWith({int? hp, int? maxHp, int? attack, int? defense}) {
    return HeroStats(
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
    );
  }

  @override
  List<Object?> get props => [hp, maxHp, attack, defense];
}

class Hero extends Equatable {
  final String id;
  final String name;
  final HeroStats stats;

  const Hero({required this.id, required this.name, required this.stats});

  Hero copyWith({String? id, String? name, HeroStats? stats}) {
    return Hero(
      id: id ?? this.id,
      name: name ?? this.name,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [id, name, stats];
}
