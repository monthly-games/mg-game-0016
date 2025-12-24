import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../data/mock_data.dart';

class DeckScreen extends StatelessWidget {
  const DeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Deck deck = MockData.starterDeck;

    return Scaffold(
      appBar: AppBar(title: const Text('My Deck')),
      body: ListView.builder(
        itemCount: deck.cards.length,
        itemBuilder: (context, index) {
          final card = deck.cards[index];
          return ListTile(
            leading: CircleAvatar(child: Text(card.cost.toString())),
            title: Text(card.name),
            subtitle: Text(card.effect.description),
            trailing: Text(card.type.name.toUpperCase()),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.swords),
        onPressed: () {
          Navigator.pushNamed(context, '/battle');
        },
      ),
    );
  }
}
