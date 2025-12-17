import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'features/cards/deck_manager.dart';
import 'features/cards/card_collection.dart';
import 'game/battle_game.dart';
import 'screens/deck_builder_screen.dart';
import 'screens/card_shop_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  await GetIt.I<AudioManager>().initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeckManager()),
        ChangeNotifierProvider(create: (_) => CardCollection()),
      ],
      child: const DeckGameApp(),
    ),
  );
}

void _setupDI() {
  if (!GetIt.I.isRegistered<AudioManager>()) {
    GetIt.I.registerSingleton<AudioManager>(AudioManager());
  }
}

class DeckGameApp extends StatelessWidget {
  const DeckGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deckbuilding Heroes',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deckbuilding Heroes'),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: Consumer<CardCollection>(
        builder: (context, collection, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Currency display
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
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
                        collection.gold,
                        Colors.yellow,
                      ),
                      _buildCurrencyItem(
                        Icons.diamond,
                        collection.crystals,
                        Colors.cyan,
                      ),
                      _buildCurrencyItem(
                        Icons.auto_fix_high,
                        collection.cardFragments,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Main menu buttons
                _buildMenuButton(
                  context,
                  'Start Battle',
                  Icons.swords,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BattleScreen()),
                    );
                  },
                ),
                _buildMenuButton(
                  context,
                  'Deck Builder',
                  Icons.style,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DeckBuilderScreen()),
                    );
                  },
                ),
                _buildMenuButton(
                  context,
                  'Card Shop',
                  Icons.store,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CardShopScreen()),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Deck status
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Current Deck',
                        style: AppTextStyles.header3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${collection.currentDeck.length}/30 cards',
                        style: AppTextStyles.body.copyWith(
                          color: collection.isDeckValid()
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      Text(
                        'Total Cards: ${collection.ownedCards.values.fold(0, (sum, count) => sum + count)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyItem(IconData icon, int amount, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          '$amount',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<DeckManager>(
        builder: (context, deckManager, child) {
          return GameWidget(
            game: BattleGame(deckManager: deckManager),
            overlayBuilderMap: {
              'HUD': (context, BattleGame game) {
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mana
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.panel,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Text(
                            "Mana: ${game.currentMana}/${game.maxMana}",
                            style: AppTextStyles.header2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Draw Pile: ${deckManager.drawPile.length}",
                          style: AppTextStyles.body,
                        ),
                        Text(
                          "Discard Pile: ${deckManager.discardPile.length}",
                          style: AppTextStyles.body,
                        ),
                        const Spacer(),
                        // End Turn Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              try {
                                GetIt.I<AudioManager>().playSfx(
                                  'sfx_click.wav',
                                );
                              } catch (_) {}
                              // TODO: End Turn logic
                              print("End Turn Clicked");
                              game.endTurn(); // Call game end turn logic
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.textHighEmphasis,
                            ),
                            child: const Text("End Turn"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            },
            initialActiveOverlays: const ['HUD'],
          );
        },
      ),
    );
  }
}
