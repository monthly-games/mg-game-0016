import 'package:equatable/equatable.dart';

enum CardRarity { common, rare, epic, legendary }

enum CardType { attack, defense, skill }

class CardEffect extends Equatable {
  final String description;
  final int value;
  // potentially add EffectType enum later (damage, heal, buff)

  const CardEffect({required this.description, required this.value});

  @override
  List<Object?> get props => [description, value];

  Map<String, dynamic> toJson() {
    return {'description': description, 'value': value};
  }

  factory CardEffect.fromJson(Map<String, dynamic> json) {
    return CardEffect(
      description: json['description'] as String,
      value: json['value'] as int,
    );
  }
}

class Card extends Equatable {
  final String id;
  final String name;
  final int cost;
  final CardRarity rarity;
  final CardType type;
  final CardEffect effect;
  final String? imageUrl;
  final int level;

  const Card({
    required this.id,
    required this.name,
    required this.cost,
    required this.rarity,
    required this.type,
    required this.effect,
    this.imageUrl,
    this.level = 1,
  });

  Card copyWith({
    String? id,
    String? name,
    int? cost,
    CardRarity? rarity,
    CardType? type,
    CardEffect? effect,
    String? imageUrl,
    int? level,
  }) {
    return Card(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      rarity: rarity ?? this.rarity,
      type: type ?? this.type,
      effect: effect ?? this.effect,
      imageUrl: imageUrl ?? this.imageUrl,
      level: level ?? this.level,
    );
  }

  @override
  List<Object?> get props => [id, name, cost, rarity, type, effect, level];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
      'rarity': rarity.index,
      'type': type.index,
      'effect': effect.toJson(),
      'imageUrl': imageUrl,
      'level': level,
    };
  }

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'] as String,
      name: json['name'] as String,
      cost: json['cost'] as int,
      rarity: CardRarity.values[json['rarity'] as int],
      type: CardType.values[json['type'] as int],
      effect: CardEffect.fromJson(json['effect'] as Map<String, dynamic>),
      imageUrl: json['imageUrl'] as String?,
      level: json['level'] as int? ?? 1,
    );
  }
}
