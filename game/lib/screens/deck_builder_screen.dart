import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/cards/card_collection.dart';
import '../models/card.dart' as model;

class DeckBuilderScreen extends StatelessWidget {
  const DeckBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<CardCollection>(
          builder: (context, collection, child) {
            return Text('Deck Builder (${collection.currentDeck.length}/30)');
          },
        ),
      ),
      body: Consumer<CardCollection>(
        builder: (context, collection, child) {
          if (collection.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // 1. Current Deck Section (Top)
              Container(
                height: 150,
                color: Colors.black12,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Deck",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: collection.currentDeck.length,
                        itemBuilder: (context, index) {
                          final cardId = collection.currentDeck[index];
                          final card = collection.getCardById(cardId);
                          if (card == null) return const SizedBox();

                          return GestureDetector(
                            onTap: () => collection.removeCardFromDeck(cardId),
                            child: CardItem(card: card, isSmall: true),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 2. Collection Section (Bottom)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Collection",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: collection.ownedCards.length,
                          itemBuilder: (context, index) {
                            String cardId = collection.ownedCards.keys
                                .elementAt(index);
                            int count = collection.ownedCards[cardId]!;
                            final card = collection.getCardById(cardId);

                            if (card == null) return const SizedBox();

                            // Determine how many used
                            int used = collection.currentDeck
                                .where((id) => id == cardId)
                                .length;
                            int available = count - used;

                            return GestureDetector(
                              onTap: available > 0
                                  ? () => collection.addCardToDeck(cardId)
                                  : null,
                              child: Opacity(
                                opacity: available > 0 ? 1.0 : 0.5,
                                child: Stack(
                                  children: [
                                    CardItem(card: card),
                                    Positioned(
                                      right: 4,
                                      bottom: 4,
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.black54,
                                        child: Text(
                                          "$available",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  final model.Card card;
  final bool isSmall;

  const CardItem({super.key, required this.card, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isSmall ? 80 : null,
      margin: isSmall ? const EdgeInsets.only(right: 8) : null,
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white30),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 10 : 14,
            ),
          ),
          if (!isSmall) ...[
            const SizedBox(height: 4),
            Text(
              "${card.cost} Mana",
              style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
            ),
            const SizedBox(height: 4),
            Text(
              card.effect.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}
