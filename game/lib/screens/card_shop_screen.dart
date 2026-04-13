import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import '../models/card.dart' as model;
import '../features/cards/card_collection.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';import 'package:mg_common_game/l10n/localization.dart';


class CardShopScreen extends StatelessWidget {
  const CardShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('shop_card_shop'.tr),
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
                  padding: const EdgeInsets.all(MGSpacing.md),
                  children: [
                    _buildShopItem(
                      context,
                      title: 'Basic Pack',
                      description:
                          '5 random cards\n70% Common, 20% Rare, 8% Epic, 2% Legendary',
                      cost: 100,
                      currencyType: 'Gold',
                      icon: Icons.card_giftcard,
                      color: MGColors.common,
                      onPurchase: () =>
                          _openPack(context, collection, 100, 'gold'),
                      canAfford: collection.gold >= 100,
                    ),
                    _buildShopItem(
                      context,
                      title: 'Premium Pack',
                      description:
                          '5 random cards\nGuaranteed 1 Rare or better!',
                      cost: 50,
                      currencyType: 'Crystals',
                      icon: Icons.stars,
                      color: MGColors.info,
                      onPurchase: () =>
                          _openPack(context, collection, 50, 'crystal'),
                      canAfford: collection.crystals >= 50,
                    ),
                    _buildShopItem(
                      context,
                      title: 'Legendary Pack',
                      description:
                          '10 random cards\nGuaranteed 1 Epic or better!',
                      cost: 150,
                      currencyType: 'Crystals',
                      icon: Icons.diamond,
                      color: MGColors.warning,
                      onPurchase: () => _openPack(
                        context,
                        collection,
                        150,
                        'crystal',
                        guaranteed: model.CardRarity.epic,
                      ),
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
      padding: const EdgeInsets.all(MGSpacing.md),
      margin: const EdgeInsets.all(MGSpacing.xs),
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
        const SizedBox(width: MGSpacing.xs),
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
              style: AppTextStyles.subHeader.copyWith(color: color),
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
      // Use Material Card Widget
      color: AppColors.panel,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(MGSpacing.md),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),

            const SizedBox(width: MGSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subHeader.copyWith(color: color),
                  ),
                  const SizedBox(height: MGSpacing.xxs),
                  Text(description, style: AppTextStyles.caption),
                ],
              ),
            ),

            // Purchase button
            ElevatedButton(
              onPressed: canAfford ? onPurchase : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford
                    ? AppColors.primary
                    : AppColors.textDisabled,
                foregroundColor: MGColors.textHighEmphasis,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
                  Text(currencyType, style: const TextStyle(fontSize: 10)),
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
    model.CardRarity? guaranteed,
  }) {
    // Check and spend currency
    bool success = false;
    if (currencyType == 'gold') {
      success = collection.trySpendGold(cost);
    } else {
      success = collection.spendCrystals(cost);
    }

    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ui_general_not_enough_currency'.tr)));
      return;
    }

    // Open pack
    final packSize = cost > 100 ? 10 : 5;
    // Call with named parameters
    final cards = collection.openCardPack(
      packSize: packSize,
      guaranteed: guaranteed,
    );

    // Show pack opening animation
    _showPackOpeningDialog(context, cards);
  }

  void _showPackOpeningDialog(BuildContext context, List<model.Card> cards) {
    // Use model.Card
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Pack Opened!',
          style: TextStyle(color: MGColors.textHighEmphasis),
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
            child: Text('ui_general_diwali_token_collection'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildCardReveal(model.Card card) {
    // Use model.Card
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getRarityColor(card.rarity), width: 3),
        boxShadow: [
          BoxShadow(
            color: _getRarityColor(card.rarity).withValues(alpha: 0.5),
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
          const SizedBox(height: MGSpacing.xxs),
          Text(
            _getRarityName(card.rarity),
            style: TextStyle(color: _getRarityColor(card.rarity), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(model.CardRarity rarity) {
    switch (rarity) {
      case model.CardRarity.common:
        return MGColors.common;
      case model.CardRarity.rare:
        return MGColors.info;
      case model.CardRarity.epic:
        return Colors.purple;
      case model.CardRarity.legendary:
        return MGColors.warning;
    }
  }

  String _getRarityName(model.CardRarity rarity) {
    switch (rarity) {
      case model.CardRarity.common:
        return 'Common';
      case model.CardRarity.rare:
        return 'Rare';
      case model.CardRarity.epic:
        return 'Epic';
      case model.CardRarity.legendary:
        return 'Legendary';
    }
  }
}
