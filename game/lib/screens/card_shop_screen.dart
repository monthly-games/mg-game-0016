import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import '../features/cards/card_collection.dart';
import '../features/cards/card_data.dart';

class CardShopScreen extends StatelessWidget {
  const CardShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Shop'),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: Consumer<CardCollection>(
        builder: (context, collection, child) {
          return Column(
            children: [
              // Currency display
              _buildCurrencyBar(collection),

              // Shop items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildShopItem(
                      context,
                      title: 'Basic Pack',
                      description: '5 random cards\n70% Common, 20% Rare, 8% Epic, 2% Legendary',
                      cost: 100,
                      currencyType: 'Gold',
                      icon: Icons.card_giftcard,
                      color: Colors.grey,
                      onPurchase: () => _openPack(context, collection, 100, 'gold'),
                      canAfford: collection.gold >= 100,
                    ),
                    _buildShopItem(
                      context,
                      title: 'Premium Pack',
                      description: '5 random cards\nGuaranteed 1 Rare or better!',
                      cost: 50,
                      currencyType: 'Crystals',
                      icon: Icons.stars,
                      color: Colors.blue,
                      onPurchase: () => _openPack(context, collection, 50, 'crystal'),
                      canAfford: collection.crystals >= 50,
                    ),
                    _buildShopItem(
                      context,
                      title: 'Legendary Pack',
                      description: '10 random cards\nGuaranteed 1 Epic or better!',
                      cost: 150,
                      currencyType: 'Crystals',
                      icon: Icons.diamond,
                      color: Colors.orange,
                      onPurchase: () => _openPack(context, collection, 150, 'crystal', guaranteed: CardRarity.epic),
                      canAfford: collection.crystals >= 150,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrencyBar(CardCollection collection) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCurrencyItem(
            Icons.monetization_on,
            'Gold',
            collection.gold,
            Colors.yellow,
          ),
          _buildCurrencyItem(
            Icons.diamond,
            'Crystals',
            collection.crystals,
            Colors.cyan,
          ),
          _buildCurrencyItem(
            Icons.auto_fix_high,
            'Fragments',
            collection.cardFragments,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem(
    IconData icon,
    String label,
    int amount,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMediumEmphasis,
              ),
            ),
            Text(
              '$amount',
              style: AppTextStyles.header3.copyWith(color: color),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShopItem(
    BuildContext context, {
    required String title,
    required String description,
    required int cost,
    required String currencyType,
    required IconData icon,
    required Color color,
    required VoidCallback onPurchase,
    required bool canAfford,
  }) {
    return Card(
      color: AppColors.panel,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),

            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.header3.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // Purchase button
            ElevatedButton(
              onPressed: canAfford ? onPurchase : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? AppColors.primary : AppColors.textDisabled,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$cost',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currencyType,
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPack(
    BuildContext context,
    CardCollection collection,
    int cost,
    String currencyType, {
    CardRarity? guaranteed,
  }) {
    // Check and spend currency
    bool success = false;
    if (currencyType == 'gold') {
      success = collection.spendGold(cost);
    } else {
      success = collection.spendCrystals(cost);
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough currency!')),
      );
      return;
    }

    // Open pack
    final packSize = cost > 100 ? 10 : 5;
    final cards = collection.openCardPack(packSize: packSize);

    // Show pack opening animation
    _showPackOpeningDialog(context, cards);
  }

  void _showPackOpeningDialog(BuildContext context, List<CardData> cards) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Pack Opened!',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return _buildCardReveal(card);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardReveal(CardData card) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getRarityColor(card.rarity),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _getRarityColor(card.rarity).withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.name,
            style: TextStyle(
              color: _getRarityColor(card.rarity),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Text(
            _getRarityName(card.rarity),
            style: TextStyle(
              color: _getRarityColor(card.rarity),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
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

  String _getRarityName(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return 'Common';
      case CardRarity.rare:
        return 'Rare';
      case CardRarity.epic:
        return 'Epic';
      case CardRarity.legendary:
        return 'Legendary';
    }
  }
}
