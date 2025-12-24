import 'package:flutter/foundation.dart';
import '../../models/card.dart';
import '../../models/deck.dart';
import '../../models/player_data.dart';
import '../persistence/save_manager.dart';
import '../../data/mock_data.dart';

class CardCollection extends ChangeNotifier {
  PlayerData _playerData = PlayerData.initial();
  final Map<String, Card> _cardDatabase = {}; // All existing cards game-wide

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<String> get currentDeck => _playerData.currentDeck;
  Map<String, int> get ownedCards => _playerData.ownedCards;
  int get gold => _playerData.gold;
  int get crystals => _playerData.crystals;
  int get cardFragments => _playerData.cardFragments;

  CardCollection() {
    _initialize();
  }

  Future<void> _initialize() async {
    // 1. Load Card DB (Mock for now)
    _loadCardDatabase();

    // 2. Load Player Persistence
    final savedData = await SaveManager().loadPlayerData();
    if (savedData != null) {
      _playerData = savedData;
    } else {
      // First time? Give starter deck
      _playerData = _createStarterData();
      await SaveManager().savePlayerData(_playerData);
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadCardDatabase() {
    _cardDatabase[MockData.strike.id] = MockData.strike;
    _cardDatabase[MockData.defend.id] = MockData.defend;
    _cardDatabase[MockData.heavyHit.id] = MockData.heavyHit;
    _cardDatabase[MockData.quickSlash.id] = MockData.quickSlash;
    _cardDatabase[MockData.heal.id] = MockData.heal;
    _cardDatabase[MockData.fireball.id] = MockData.fireball;
    _cardDatabase[MockData.ultimate.id] = MockData.ultimate;
  }

  PlayerData _createStarterData() {
    // 5 Strikes, 5 Defends
    Map<String, int> owned = {};
    List<String> deck = [];

    // Give 10 of each starter card
    owned[MockData.strike.id] = 10;
    owned[MockData.defend.id] = 10;

    // Build initial deck (30 cards needed eventually, but for now 10)
    for (int i = 0; i < 5; i++) {
      deck.add(MockData.strike.id);
    }
    for (int i = 0; i < 5; i++) {
      deck.add(MockData.defend.id);
    }

    return PlayerData(ownedCards: owned, currentDeck: deck, gold: 100);
  }

  // --- Deck Editing ---

  bool isDeckValid() {
    return _playerData.currentDeck.length == 30;
  }

  Card? getCardById(String id) => _cardDatabase[id];

  void addCardToDeck(String cardId) {
    if (_playerData.currentDeck.length >= 30) {
      // Deck full
      return;
    }

    // Check ownership
    // Count how many we own vs how many in deck
    int ownedCount = _playerData.ownedCards[cardId] ?? 0;
    int inDeckCount = _playerData.currentDeck
        .where((id) => id == cardId)
        .length;

    if (inDeckCount < ownedCount) {
      List<String> newDeck = List.from(_playerData.currentDeck)..add(cardId);
      _updatePlayerData(_playerData.copyWith(currentDeck: newDeck));
    }
  }

  void removeCardFromDeck(String cardId) {
    if (_playerData.currentDeck.contains(cardId)) {
      List<String> newDeck = List.from(_playerData.currentDeck);
      newDeck.remove(cardId); // Removes first instance
      _updatePlayerData(_playerData.copyWith(currentDeck: newDeck));
    }
  }

  Future<void> _updatePlayerData(PlayerData newData) async {
    _playerData = newData;
    notifyListeners();
    await SaveManager().savePlayerData(_playerData);
  }

  // --- Shop & Currency ---

  bool spendGold(int amount) {
    if (_playerData.gold >= amount) {
      _updatePlayerData(_playerData.copyWith(gold: _playerData.gold - amount));
      return true;
    }
    return false;
  }

  bool spendCrystals(int amount) {
    if (_playerData.crystals >= amount) {
      _updatePlayerData(
        _playerData.copyWith(crystals: _playerData.crystals - amount),
      );
      return true;
    }
    return false;
  }

  List<Card> openCardPack({required int packSize, CardRarity? guaranteed}) {
    // For now, return random cards from mock DB
    List<Card> newCards = [];
    final allCards = _cardDatabase.values.toList();

    for (int i = 0; i < packSize; i++) {
      // Simple random pick
      // TODO: Implement actual rarity logic based on 'guaranteed'
      final card = allCards[DateTime.now().microsecond % allCards.length];
      newCards.add(card);
      _addCardToCollection(card.id);
    }
    return newCards;
  }

  void _addCardToCollection(String cardId) {
    Map<String, int> owned = Map.from(_playerData.ownedCards);
    owned[cardId] = (owned[cardId] ?? 0) + 1;
    _updatePlayerData(_playerData.copyWith(ownedCards: owned));
  }

  void updatePlayerDataExternal(PlayerData newData) {
    _updatePlayerData(newData);
  }

  // --- Upgrades ---

  int getCardLevel(String cardId) => _playerData.cardLevels[cardId] ?? 1;

  bool canUpgradeCard(String cardId) {
    if (!(_playerData.ownedCards.containsKey(cardId))) return false;
    int currentLevel = getCardLevel(cardId);
    int cost = currentLevel * 50; // Simple cost formula
    return _playerData.gold >= cost;
  }

  void upgradeCard(String cardId) {
    if (canUpgradeCard(cardId)) {
      int currentLevel = getCardLevel(cardId);
      int cost = currentLevel * 50;

      // Deduct Gold
      int newGold = _playerData.gold - cost;

      // Increase Level
      Map<String, int> newLevels = Map.from(_playerData.cardLevels);
      newLevels[cardId] = currentLevel + 1;

      _updatePlayerData(
        _playerData.copyWith(gold: newGold, cardLevels: newLevels),
      );
    }
  }

  // --- Campaign Helpers ---

  PlayerData get playerData => _playerData;

  void addGold(int amount) {
    _updatePlayerData(_playerData.copyWith(gold: _playerData.gold + amount));
  }

  void addCrystals(int amount) {
    _updatePlayerData(
      _playerData.copyWith(crystals: _playerData.crystals + amount),
    );
  }

  void unlockStage(String stageId) {
    if (!_playerData.unlockedStageIds.contains(stageId)) {
      List<String> newUnlocked = List.from(_playerData.unlockedStageIds)
        ..add(stageId);
      _updatePlayerData(_playerData.copyWith(unlockedStageIds: newUnlocked));
    }
  }

  // Helper for UI
  Deck getDeckObject() {
    List<Card> cards = [];
    for (String id in _playerData.currentDeck) {
      final card = _cardDatabase[id];
      if (card != null) {
        // Apply Level
        int level = getCardLevel(id);
        cards.add(card.copyWith(level: level));
      }
    }
    return Deck(cards: cards);
  }
}
