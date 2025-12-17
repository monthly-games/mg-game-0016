import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'card_data.dart';

/// Manages player's card collection and deck building
class CardCollection extends ChangeNotifier {
  // Player's owned cards (card name -> count)
  Map<String, int> _ownedCards = {};
  Map<String, int> get ownedCards => Map.unmodifiable(_ownedCards);

  // Player's current deck (30 cards, max 2 copies per card)
  List<CardData> _currentDeck = [];
  List<CardData> get currentDeck => List.unmodifiable(_currentDeck);

  // Currencies
  int _gold = 100;
  int get gold => _gold;

  int _crystals = 50;
  int get crystals => _crystals;

  int _cardFragments = 0;
  int get cardFragments => _cardFragments;

  // Deck constraints
  static const int deckSize = 30;
  static const int maxCopiesPerCard = 2;

  CardCollection() {
    _initializeStarterCollection();
    loadProgress();
  }

  void _initializeStarterCollection() {
    // Starter cards (matching DeckManager's starting deck)
    _ownedCards['Strike'] = 5;
    _ownedCards['Defend'] = 5;
    _ownedCards['Bash'] = 2;

    // Build initial deck
    _currentDeck.clear();
    _currentDeck.addAll(List.generate(5, (_) => CardData.strike()));
    _currentDeck.addAll(List.generate(4, (_) => CardData.defend()));
    _currentDeck.add(CardData.bash());
  }

  /// Add a card to collection
  void addCard(CardData card) {
    _ownedCards[card.name] = (_ownedCards[card.name] ?? 0) + 1;
    notifyListeners();
    saveProgress();
  }

  /// Remove a card from collection (for crafting/selling)
  bool removeCard(String cardName) {
    if ((_ownedCards[cardName] ?? 0) <= 0) return false;

    _ownedCards[cardName] = _ownedCards[cardName]! - 1;
    if (_ownedCards[cardName] == 0) {
      _ownedCards.remove(cardName);
    }

    notifyListeners();
    saveProgress();
    return true;
  }

  /// Add card to deck (if valid)
  bool addToDeck(CardData card) {
    // Check deck size
    if (_currentDeck.length >= deckSize) return false;

    // Check max copies
    int currentCopies = _currentDeck.where((c) => c.name == card.name).length;
    if (currentCopies >= maxCopiesPerCard) return false;

    // Check if player owns the card
    if ((_ownedCards[card.name] ?? 0) <= 0) return false;

    _currentDeck.add(card);
    notifyListeners();
    saveProgress();
    return true;
  }

  /// Remove card from deck
  bool removeFromDeck(CardData card) {
    if (!_currentDeck.contains(card)) return false;

    _currentDeck.remove(card);
    notifyListeners();
    saveProgress();
    return true;
  }

  /// Clear entire deck
  void clearDeck() {
    _currentDeck.clear();
    notifyListeners();
    saveProgress();
  }

  /// Check if deck is valid (30 cards)
  bool isDeckValid() {
    return _currentDeck.length == deckSize;
  }

  /// Get all available cards (for card pool)
  static List<CardData> getAllCards() {
    return [
      // Common (70% drop rate)
      CardData.strike(),
      CardData.defend(),
      CardData.bash(),
      // Rare (20% drop rate)
      CardData.fireball(),
      CardData.shield(),
      // Epic (8% drop rate)
      CardData.meteor(),
      CardData.ironWall(),
      // Legendary (2% drop rate)
      CardData.divineStrike(),
    ];
  }

  /// Open a card pack (gacha system)
  List<CardData> openCardPack({int packSize = 5}) {
    final random = Random();
    final allCards = getAllCards();
    final drawnCards = <CardData>[];

    for (int i = 0; i < packSize; i++) {
      // Rarity roll (70% common, 20% rare, 8% epic, 2% legendary)
      double roll = random.nextDouble() * 100;
      CardRarity targetRarity;

      if (roll < 2) {
        targetRarity = CardRarity.legendary;
      } else if (roll < 10) {
        targetRarity = CardRarity.epic;
      } else if (roll < 30) {
        targetRarity = CardRarity.rare;
      } else {
        targetRarity = CardRarity.common;
      }

      // Get cards of target rarity
      final cardsOfRarity = allCards.where((c) => c.rarity == targetRarity).toList();
      if (cardsOfRarity.isEmpty) {
        // Fallback to common if no cards found
        targetRarity = CardRarity.common;
        cardsOfRarity.addAll(allCards.where((c) => c.rarity == targetRarity));
      }

      // Pick random card
      final card = cardsOfRarity[random.nextInt(cardsOfRarity.length)];
      drawnCards.add(card);
      addCard(card);
    }

    return drawnCards;
  }

  /// Spend gold
  bool spendGold(int amount) {
    if (_gold < amount) return false;
    _gold -= amount;
    notifyListeners();
    saveProgress();
    return true;
  }

  /// Spend crystals
  bool spendCrystals(int amount) {
    if (_crystals < amount) return false;
    _crystals -= amount;
    notifyListeners();
    saveProgress();
    return true;
  }

  /// Add gold
  void addGold(int amount) {
    _gold += amount;
    notifyListeners();
    saveProgress();
  }

  /// Add crystals
  void addCrystals(int amount) {
    _crystals += amount;
    notifyListeners();
    saveProgress();
  }

  /// Add card fragments
  void addCardFragments(int amount) {
    _cardFragments += amount;
    notifyListeners();
    saveProgress();
  }

  /// Save progress to SharedPreferences
  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('ownedCards', jsonEncode(_ownedCards));
    await prefs.setInt('gold', _gold);
    await prefs.setInt('crystals', _crystals);
    await prefs.setInt('cardFragments', _cardFragments);

    // Save current deck (card names only)
    final deckNames = _currentDeck.map((c) => c.name).toList();
    await prefs.setString('currentDeck', jsonEncode(deckNames));
  }

  /// Load progress from SharedPreferences
  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load owned cards
      final ownedCardsJson = prefs.getString('ownedCards');
      if (ownedCardsJson != null) {
        final decoded = jsonDecode(ownedCardsJson) as Map<String, dynamic>;
        _ownedCards = decoded.map((key, value) => MapEntry(key, value as int));
      }

      // Load currencies
      _gold = prefs.getInt('gold') ?? 100;
      _crystals = prefs.getInt('crystals') ?? 50;
      _cardFragments = prefs.getInt('cardFragments') ?? 0;

      // Load current deck
      final deckJson = prefs.getString('currentDeck');
      if (deckJson != null) {
        final deckNames = (jsonDecode(deckJson) as List).cast<String>();
        _currentDeck.clear();

        for (final name in deckNames) {
          // Reconstruct cards from names
          final card = _cardFromName(name);
          if (card != null) {
            _currentDeck.add(card);
          }
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  /// Helper: Get card from name
  CardData? _cardFromName(String name) {
    switch (name) {
      case 'Strike':
        return CardData.strike();
      case 'Defend':
        return CardData.defend();
      case 'Bash':
        return CardData.bash();
      case 'Fireball':
        return CardData.fireball();
      case 'Shield':
        return CardData.shield();
      case 'Meteor':
        return CardData.meteor();
      case 'Iron Wall':
        return CardData.ironWall();
      case 'Divine Strike':
        return CardData.divineStrike();
      default:
        return null;
    }
  }

  /// Reset all progress (for testing)
  void resetProgress() {
    _ownedCards.clear();
    _currentDeck.clear();
    _gold = 100;
    _crystals = 50;
    _cardFragments = 0;
    _initializeStarterCollection();
    saveProgress();
    notifyListeners();
  }
}
