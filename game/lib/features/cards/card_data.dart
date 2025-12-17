import 'package:uuid/uuid.dart';

enum CardType { attack, skill, defence }

enum CardRarity { common, rare, epic, legendary }

class CardData {
  final String id;
  final String name;
  final String description;
  final int cost;
  final CardType type;
  final int value; // Damage or Block amount
  final CardRarity rarity;
  final int level; // Card upgrade level (1-10)

  CardData({
    String? id,
    required this.name,
    required this.description,
    required this.cost,
    required this.type,
    required this.value,
    this.rarity = CardRarity.common,
    this.level = 1,
  }) : id = id ?? const Uuid().v4();

  // Factory constructors for common cards
  factory CardData.strike() => CardData(
    name: "Strike",
    description: "Deal 6 damage.",
    cost: 1,
    type: CardType.attack,
    value: 6,
  );

  factory CardData.defend() => CardData(
    name: "Defend",
    description: "Gain 5 Block.",
    cost: 1,
    type: CardType.defence,
    value: 5,
  );

  factory CardData.bash() => CardData(
    name: "Bash",
    description: "Deal 8 damage. (High Cost)",
    cost: 2,
    type: CardType.attack,
    value: 8,
    rarity: CardRarity.common,
  );

  // Additional card constructors
  factory CardData.fireball() => CardData(
    name: "Fireball",
    description: "Deal 12 damage.",
    cost: 2,
    type: CardType.attack,
    value: 12,
    rarity: CardRarity.rare,
  );

  factory CardData.shield() => CardData(
    name: "Shield",
    description: "Gain 10 Block.",
    cost: 2,
    type: CardType.defence,
    value: 10,
    rarity: CardRarity.rare,
  );

  factory CardData.meteor() => CardData(
    name: "Meteor",
    description: "Deal 20 damage.",
    cost: 3,
    type: CardType.attack,
    value: 20,
    rarity: CardRarity.epic,
  );

  factory CardData.ironWall() => CardData(
    name: "Iron Wall",
    description: "Gain 15 Block.",
    cost: 2,
    type: CardType.defence,
    value: 15,
    rarity: CardRarity.epic,
  );

  factory CardData.divineStrike() => CardData(
    name: "Divine Strike",
    description: "Deal 30 damage.",
    cost: 3,
    type: CardType.attack,
    value: 30,
    rarity: CardRarity.legendary,
  );

  // Copy with level upgrade
  CardData copyWithLevel(int newLevel) {
    return CardData(
      id: id,
      name: name,
      description: description,
      cost: cost,
      type: type,
      value: value + (newLevel - level) * 2, // +2 value per level
      rarity: rarity,
      level: newLevel,
    );
  }
}
