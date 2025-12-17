import 'package:flutter/foundation.dart';
import 'card_data.dart';

class DeckManager extends ChangeNotifier {
  List<CardData> drawPile = [];
  List<CardData> hand = [];
  List<CardData> discardPile = [];

  // Max cards in hand
  final int maxHandSize = 5;

  DeckManager() {
    _initDeck();
  }

  void _initDeck() {
    // Starting Deck: 5 Strikes, 4 Defends, 1 Bash
    drawPile.addAll(List.generate(5, (_) => CardData.strike()));
    drawPile.addAll(List.generate(4, (_) => CardData.defend()));
    drawPile.add(CardData.bash());

    drawPile.shuffle();
  }

  void drawCards(int amount) {
    for (int i = 0; i < amount; i++) {
      if (hand.length >= 10) break; // Hard limit

      if (drawPile.isEmpty) {
        if (discardPile.isEmpty) break; // No cards left
        resuffleDiscard();
      }

      hand.add(drawPile.removeLast());
    }
    notifyListeners();
  }

  void playCard(CardData card) {
    if (hand.contains(card)) {
      hand.remove(card);
      discardPile.add(card);
      notifyListeners();
    }
  }

  void discardHand() {
    discardPile.addAll(hand);
    hand.clear();
    notifyListeners();
  }

  void resuffleDiscard() {
    drawPile.addAll(discardPile);
    discardPile.clear();
    drawPile.shuffle();
    notifyListeners(); // Notify if visualizer needs to show shuffle anim
  }
}
