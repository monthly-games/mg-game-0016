import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import '../features/cards/card_collection.dart';
import '../features/cards/card_data.dart';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        backgroundColor: AppColors.primary,
        actions: [
          // Save deck button
          Consumer<CardCollection>(
            builder: (context, collection, child) {
              final isValid = collection.isDeckValid();
              return TextButton.icon(
                onPressed: isValid
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Deck saved!')),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                icon: const Icon(Icons.save, color: Colors.white),
                label: Text(
                  'Save (${collection.currentDeck.length}/30)',
                  style: TextStyle(
                    color: isValid ? Colors.white : Colors.white54,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Consumer<CardCollection>(
        builder: (context, collection, child) {
          return Row(
            children: [
              // Left: Collection
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Filter bar
                    _buildFilterBar(),
                    // Card collection grid
                    Expanded(
                      child: _buildCollectionGrid(collection),
                    ),
                  ],
                ),
              ),

              // Right: Current deck
              Expanded(
                flex: 2,
                child: Container(
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      // Deck header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.primary),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Deck',
                              style: AppTextStyles.header2,
                            ),
                            TextButton.icon(
                              onPressed: () {
                                collection.clearDeck();
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Clear'),
                            ),
                          ],
                        ),
                      ),

                      // Deck cards list
                      Expanded(
                        child: _buildDeckList(collection),
                      ),

                      // Deck stats
                      _buildDeckStats(collection),
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

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: AppColors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All'),
            _buildFilterChip('Attack'),
            _buildFilterChip('Defence'),
            _buildFilterChip('Skill'),
            const SizedBox(width: 16),
            _buildFilterChip('Common'),
            _buildFilterChip('Rare'),
            _buildFilterChip('Epic'),
            _buildFilterChip('Legendary'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? label : 'All';
          });
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.panel,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textMediumEmphasis,
        ),
      ),
    );
  }

  Widget _buildCollectionGrid(CardCollection collection) {
    final allCards = CardCollection.getAllCards();

    // Apply filter
    final filteredCards = allCards.where((card) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Attack') return card.type == CardType.attack;
      if (_selectedFilter == 'Defence') return card.type == CardType.defence;
      if (_selectedFilter == 'Skill') return card.type == CardType.skill;
      if (_selectedFilter == 'Common') return card.rarity == CardRarity.common;
      if (_selectedFilter == 'Rare') return card.rarity == CardRarity.rare;
      if (_selectedFilter == 'Epic') return card.rarity == CardRarity.epic;
      if (_selectedFilter == 'Legendary') {
        return card.rarity == CardRarity.legendary;
      }
      return true;
    }).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: filteredCards.length,
      itemBuilder: (context, index) {
        final card = filteredCards[index];
        final ownedCount = collection.ownedCards[card.name] ?? 0;
        final inDeckCount =
            collection.currentDeck.where((c) => c.name == card.name).length;

        return _buildCardItem(
          card,
          ownedCount,
          inDeckCount,
          onTap: () {
            if (ownedCount > 0) {
              final success = collection.addToDeck(card);
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cannot add card (deck full or max copies)'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  Widget _buildDeckList(CardCollection collection) {
    if (collection.currentDeck.isEmpty) {
      return const Center(
        child: Text(
          'No cards in deck\nAdd cards from collection',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMediumEmphasis),
        ),
      );
    }

    // Group by card name
    final Map<String, List<CardData>> groupedCards = {};
    for (final card in collection.currentDeck) {
      groupedCards.putIfAbsent(card.name, () => []).add(card);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: groupedCards.length,
      itemBuilder: (context, index) {
        final cardName = groupedCards.keys.elementAt(index);
        final cards = groupedCards[cardName]!;
        final card = cards.first;

        return Card(
          color: AppColors.panel,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCardTypeColor(card.type).withOpacity(0.3),
              child: Text(
                '${card.cost}',
                style: TextStyle(
                  color: _getCardTypeColor(card.type),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              card.name,
              style: TextStyle(color: _getRarityColor(card.rarity)),
            ),
            subtitle: Text(
              '${cards.length}x • ${card.description}',
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                collection.removeFromDeck(cards.first);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeckStats(CardCollection collection) {
    final attackCount =
        collection.currentDeck.where((c) => c.type == CardType.attack).length;
    final defenceCount = collection.currentDeck
        .where((c) => c.type == CardType.defence)
        .length;
    final skillCount =
        collection.currentDeck.where((c) => c.type == CardType.skill).length;

    final avgCost = collection.currentDeck.isEmpty
        ? 0.0
        : collection.currentDeck.map((c) => c.cost).reduce((a, b) => a + b) /
            collection.currentDeck.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.primary)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Deck Statistics', style: AppTextStyles.header3),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Attack', attackCount, Colors.red),
              _buildStatItem('Defence', defenceCount, Colors.blue),
              _buildStatItem('Skill', skillCount, Colors.green),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Avg Cost: ${avgCost.toStringAsFixed(1)}',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMediumEmphasis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildCardItem(
    CardData card,
    int ownedCount,
    int inDeckCount,
    {VoidCallback? onTap},
  ) {
    final isOwned = ownedCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getRarityColor(card.rarity),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card header (cost)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getCardTypeColor(card.type).withOpacity(0.3),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
              child: Text(
                'Cost: ${card.cost}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _getCardTypeColor(card.type),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Card name
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                card.name,
                style: TextStyle(
                  color: _getRarityColor(card.rarity),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Card description
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  card.description,
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Card count
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isOwned ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(6)),
              ),
              child: Text(
                isOwned
                    ? 'Owned: $ownedCount | In Deck: $inDeckCount'
                    : 'Not Owned',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isOwned ? Colors.green : Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardTypeColor(CardType type) {
    switch (type) {
      case CardType.attack:
        return Colors.red;
      case CardType.defence:
        return Colors.blue;
      case CardType.skill:
        return Colors.green;
    }
  }

  Color _getRarityColor(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return Colors.grey;
      case CardRarity.rare:
        return Colors.blue;
      case CardRarity.epic:
        return Colors.purple;
      case CardRarity.legendary:
        return Colors.orange;
    }
  }
}
