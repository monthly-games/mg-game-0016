import '../models/card.dart';
import '../models/hero.dart';
import '../models/deck.dart';

class MockData {
  static const Hero playerHero = Hero(
    id: 'p1',
    name: 'Knight',
    stats: HeroStats(hp: 100, maxHp: 100, attack: 10, defense: 5),
  );

  static const Hero enemyHero = Hero(
    id: 'e1',
    name: 'Goblin',
    stats: HeroStats(hp: 50, maxHp: 50, attack: 8, defense: 2),
  );

  static const Card strike = Card(
    id: 'c1',
    name: 'Strike',
    cost: 1,
    rarity: CardRarity.common,
    type: CardType.attack,
    effect: CardEffect(description: 'Deal 10 damage', value: 10),
  );

  static const Card defend = Card(
    id: 'c2',
    name: 'Defend',
    cost: 1,
    rarity: CardRarity.common,
    type: CardType.defense,
    effect: CardEffect(description: 'Gain 5 block', value: 5),
  );

  static const Card heavyHit = Card(
    id: 'c3',
    name: 'Heavy Hit',
    cost: 2,
    rarity: CardRarity.rare,
    type: CardType.attack,
    effect: CardEffect(description: 'Deal 25 damage', value: 25),
  );

  static const Card quickSlash = Card(
    id: 'c4',
    name: 'Quick Slash',
    cost: 0,
    rarity: CardRarity.common,
    type: CardType.attack,
    effect: CardEffect(description: 'Deal 6 damage', value: 6),
  );

  static const Card heal = Card(
    id: 'c5',
    name: 'Holy Light',
    cost: 2,
    rarity: CardRarity.rare,
    type: CardType.defense,
    effect: CardEffect(description: 'Heal 20 HP', value: 20),
  );

  static const Card fireball = Card(
    id: 'c6',
    name: 'Fireball',
    cost: 2,
    rarity: CardRarity.rare,
    type: CardType.attack,
    effect: CardEffect(description: 'Deal 18 damage', value: 18),
  );

  static const Card ultimate = Card(
    id: 'c7',
    name: 'Meteor',
    cost: 3,
    rarity: CardRarity.legendary,
    type: CardType.attack,
    effect: CardEffect(description: 'Deal 50 damage', value: 50),
  );

  static Deck get starterDeck {
    List<Card> cards = [];
    for (int i = 0; i < 15; i++) {
      cards.add(strike);
    }
    for (int i = 0; i < 10; i++) {
      cards.add(defend);
    }
    for (int i = 0; i < 5; i++) {
      cards.add(heavyHit);
    }
    return Deck(cards: cards);
  }
}
