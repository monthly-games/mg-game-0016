import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'features/cards/card_collection.dart';

import 'screens/deck_builder_screen.dart';
import 'screens/battle_screen.dart';
import 'screens/campaign_screen.dart';
import 'features/campaign/campaign_manager.dart';
import 'features/meta/quest_manager.dart';
import 'screens/quest_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  try {
    await GetIt.I<AudioManager>().initialize();
  } catch (e) {
    debugPrint("Audio init failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CardCollection()),
        ProxyProvider<CardCollection, CampaignManager>(
          update: (context, collection, previous) =>
              previous ?? CampaignManager(collection),
        ),
        ProxyProvider<CardCollection, QuestManager>(
          update: (context, collection, previous) =>
              previous ?? QuestManager(collection),
        ),
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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/deck': (context) => const DeckBuilderScreen(),
        '/battle': (context) => const BattleScreen(),
        '/campaign': (context) => const CampaignScreen(),
        '/quests': (context) => const QuestScreen(),
      },
      onGenerateRoute: (settings) {
        // Helper for passing args if needed, though mostly using direct MaterialPageRoute
        return null;
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deckbuilding Heroes')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/campaign'),
              child: const Text('Campaign Mode'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/deck'),
              child: const Text('Manage Deck'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/quests'),
              child: const Text('Quests'),
            ),
          ],
        ),
      ),
    );
  }
}
