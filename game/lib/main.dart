import 'package:mg_common_game/mg_common_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'features/cards/card_collection.dart';

import 'screens/deck_builder_screen.dart';
import 'screens/battle_screen.dart';
import 'screens/campaign_screen.dart';
import 'features/campaign/campaign_manager.dart';
import 'features/meta/quest_manager.dart';
import 'screens/quest_screen.dart';
import 'screens/battlepass_screen.dart';
import 'screens/gacha_screen.dart';
import 'screens/daily_quest_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/collection_screen.dart';
import 'game/tutorial_config.dart';
import 'game/balancing_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  _registerCollections();
  try {
    await GetIt.I<AudioManager>().initialize();
  } catch (e) {
    debugPrint("Audio init failed: $e");
  }

  // ── Tutorial & Balancing ──────────────────────────────────
  if (!GetIt.I.isRegistered<TutorialManager>()) {
    final tutorialManager = TutorialManager();
    await tutorialManager.initialize();
    tutorialManager.registerTutorial(
      kOnboardingTutorial.id,
      kOnboardingTutorial.steps,
    );
    GetIt.I.registerSingleton<TutorialManager>(tutorialManager);
  }
  if (!GetIt.I.isRegistered<BalancingManager>()) {
    GetIt.I.registerSingleton<BalancingManager>(
      BalancingManager(defaultConfig: kDefaultBalancingConfig),
    );
  }
  // ── Q7 DI Fix: Missing Systems ──────────────────────────
  if (!GetIt.I.isRegistered<BattlePassManager>()) {
    GetIt.I.registerSingleton<BattlePassManager>(BattlePassManager());
  }
  if (!GetIt.I.isRegistered<GachaManager>()) {
    GetIt.I.registerSingleton<GachaManager>(GachaManager());
  }
  if (!GetIt.I.isRegistered<CollectionManager>()) {
    GetIt.I.registerSingleton<CollectionManager>(CollectionManager());
  }
  if (!GetIt.I.isRegistered<GuildWarManager>()) {
    GetIt.I.registerSingleton<GuildWarManager>(GuildWarManager());
  }
  if (!GetIt.I.isRegistered<TournamentManager>()) {
    GetIt.I.registerSingleton<TournamentManager>(TournamentManager());
  }
  if (!GetIt.I.isRegistered<SeasonalContentManager>()) {
    GetIt.I.registerSingleton<SeasonalContentManager>(SeasonalContentManager());
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CardCollection()),
        ChangeNotifierProvider<CollectionManager>.value(
          value: GetIt.I<CollectionManager>(),
        ),
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
  final di = GetIt.I;

  if (!di.isRegistered<AudioManager>()) {
    di.registerSingleton<AudioManager>(AudioManager());
  }
  if (!di.isRegistered<CollectionManager>()) {
    di.registerSingleton<CollectionManager>(CollectionManager());
  }
  if (!di.isRegistered<DailyQuestManager>()) {
    di.registerSingleton(DailyQuestManager());
  }
  if (!di.isRegistered<AchievementManager>()) {
    di.registerSingleton(AchievementManager());
  }
  if (!di.isRegistered<BattlePassManager>()) {
    di.registerSingleton(BattlePassManager());
  }
  if (!di.isRegistered<GachaManager>()) {
    di.registerSingleton(GachaManager());
  }
  if (!di.isRegistered<LoginRewardsManager>()) {
    di.registerSingleton(LoginRewardsManager());
  }
  if (!di.isRegistered<StreakManager>()) {
    di.registerSingleton(StreakManager());
  }
  if (!di.isRegistered<DailyChallengeManager>()) {
    di.registerSingleton(DailyChallengeManager());
  }
  if (!di.isRegistered<GuildWarManager>()) {
    di.registerSingleton(GuildWarManager());
  }
  if (!di.isRegistered<TournamentManager>()) {
    di.registerSingleton(TournamentManager());
  }
  if (!di.isRegistered<SeasonalContentManager>()) {
    di.registerSingleton(SeasonalContentManager());
  }

  _setupGacha();
  _setupBattlePass();
  _registerAchievements();
  _registerDailyQuests();
}

void _registerCollections() {
  final collectionManager = GetIt.I<CollectionManager>();

  final cardCollection = Collection(
    id: 'card_collection',
    name: 'Card Collection',
    description: 'Collect all battle cards',
    category: 'cards',
    items: const [
      CollectionItem(
        id: 'c1',
        name: 'Strike',
        description: 'Deal 10 damage',
        rarity: CollectionRarity.common,
      ),
      CollectionItem(
        id: 'c2',
        name: 'Defend',
        description: 'Gain 5 block',
        rarity: CollectionRarity.common,
      ),
      CollectionItem(
        id: 'c3',
        name: 'Heavy Hit',
        description: 'Deal 25 damage',
        rarity: CollectionRarity.rare,
      ),
      CollectionItem(
        id: 'c4',
        name: 'Quick Slash',
        description: 'Deal 6 damage',
        rarity: CollectionRarity.common,
      ),
      CollectionItem(
        id: 'c5',
        name: 'Holy Light',
        description: 'Heal 20 HP',
        rarity: CollectionRarity.epic,
      ),
      CollectionItem(
        id: 'c6',
        name: 'Fireball',
        description: 'Deal 18 damage',
        rarity: CollectionRarity.rare,
      ),
      CollectionItem(
        id: 'c7',
        name: 'Meteor',
        description: 'Deal 50 damage',
        rarity: CollectionRarity.legendary,
      ),
    ],
    milestoneRewards: const {
      25: CollectionReward(type: RewardType.gold, amount: 200),
      50: CollectionReward(type: RewardType.gold, amount: 400),
      75: CollectionReward(type: RewardType.gems, amount: 10),
    },
    completionReward: const CollectionReward(type: RewardType.gems, amount: 25),
  );

  final gachaCollection = Collection(
    id: 'gacha_collection',
    name: 'Gacha Collection',
    description: 'Collect all gacha cards',
    category: 'gacha',
    items: const [
      CollectionItem(
        id: 'ur_cardbattle_001',
        name: 'Legendary BattleCard',
        description: 'Top-tier battle card',
        rarity: CollectionRarity.legendary,
      ),
      CollectionItem(
        id: 'ssr_cardbattle_001',
        name: 'Hero BattleCard',
        description: 'High-tier battle card',
        rarity: CollectionRarity.epic,
      ),
      CollectionItem(
        id: 'sr_cardbattle_001',
        name: 'Rare BattleCard',
        description: 'Mid-tier battle card',
        rarity: CollectionRarity.rare,
      ),
      CollectionItem(
        id: 'r_cardbattle_001',
        name: 'Uncommon BattleCard',
        description: 'Entry-tier battle card',
        rarity: CollectionRarity.uncommon,
      ),
      CollectionItem(
        id: 'n_cardbattle_001',
        name: 'Common BattleCard',
        description: 'Base-tier battle card',
        rarity: CollectionRarity.common,
      ),
    ],
    milestoneRewards: const {
      25: CollectionReward(type: RewardType.gold, amount: 300),
      50: CollectionReward(type: RewardType.gold, amount: 600),
      75: CollectionReward(type: RewardType.gems, amount: 15),
    },
    completionReward: const CollectionReward(type: RewardType.gems, amount: 30),
  );

  collectionManager.registerCollections([cardCollection, gachaCollection]);

  // Setup callbacks with haptic feedback
  collectionManager.onItemUnlocked = (collectionId, itemId) {
    HapticFeedback.mediumImpact();
    debugPrint('Item unlocked: $collectionId/$itemId');
  };

  collectionManager.onMilestoneEarned =
      (collectionId, milestone, reward) {
    HapticFeedback.mediumImpact();
    debugPrint('Milestone reached: $collectionId at $milestone%');
  };

  collectionManager.onCollectionCompleted = (collectionId, reward) {
    HapticFeedback.mediumImpact();
    debugPrint('Collection completed: $collectionId');
  };
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
        '/collections': (context) => CollectionScreen(
          collectionManager: GetIt.I<CollectionManager>(),
        ),
        '/battlepass': (_) => const BattlePassScreen(),
        '/gacha': (_) => const GachaScreen(),
        '/daily-quests': (_) => const DailyQuestScreen(),
        '/achievements': (_) => const AchievementScreen(),
          '/daily_quest': (_) => const DailyQuestScreen(),
          '/achievement': (_) => const AchievementScreen(),
        '/daily-hub': (context) => DailyHubScreen(
          questManager: GetIt.I<DailyQuestManager>(),
          loginRewardsManager: GetIt.I<LoginRewardsManager>(),
          streakManager: GetIt.I<StreakManager>(),
          challengeManager: GetIt.I<DailyChallengeManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
        ),
        
        '/collection': (context) => CollectionScreen(
          collectionManager: GetIt.I<CollectionManager>(),
        ),
        '/guild-war': (context) => GuildWarScreen(
          guildWarManager: GetIt.I<GuildWarManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
          ),
        '/tournament': (context) => TournamentScreen(
          tournamentManager: GetIt.I<TournamentManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
          ),
        '/seasonal-event': (context) => SeasonalEventScreen(
          seasonalContentManager: GetIt.I<SeasonalContentManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
          ),
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/guild-war'),
              icon: const Icon(Icons.shield),
              label: const Text('Guild War'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/tournament'),
              icon: const Icon(Icons.emoji_events),
              label: const Text('Tournament'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(
                  context, '/seasonal-event'),
              icon: const Icon(Icons.celebration),
              label: const Text('Seasonal Event'),
            ),
          ],
        ),
      ),
    );
  }
}


void _registerDailyQuests() {
  final dailyQuest = GetIt.I<DailyQuestManager>();
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'collect_gold',
    title: '골드 모으기',
    description: '골드 1000 획득',
    targetValue: 1000,
    goldReward: 500,
    xpReward: 10,
  ));
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'play_games',
    title: '게임 플레이',
    description: '게임 5판 플레이',
    targetValue: 5,
    goldReward: 300,
    xpReward: 5,
  ));
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'level_up',
    title: '레벨업',
    description: '레벨 1 상승',
    targetValue: 1,
    goldReward: 200,
    xpReward: 3,
  ));
}


void _registerAchievements() {
  final achievement = GetIt.I<AchievementManager>();
  
  achievement.registerAchievement(Achievement(
    id: 'gold_1000',
    title: '골드 1000 달성',
    description: '총 골드 1000을 모으세요',
    iconAsset: 'assets/achievements/gold_1000.png',
  ));
  
  achievement.registerAchievement(Achievement(
    id: 'level_10',
    title: '레벨 10 달성',
    description: '레벨 10에 도달하세요',
    iconAsset: 'assets/achievements/level_10.png',
  ));
  
  achievement.registerAchievement(Achievement(
    id: 'play_100',
    title: '100판 플레이',
    description: '게임을 100판 플레이하세요',
    iconAsset: 'assets/achievements/play_100.png',
  ));
}


void _setupBattlePass() {
  final bp = GetIt.I<BattlePassManager>();

  final season = BPSeasonBuilder.create28DaySeason(
    id: 'season_1',
    nameKr: '시즌 1',
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    maxLevel: 50,
    expPerLevel: 1000,
  );

  bp.setSeason(season);
  bp.setMissions(
    daily: BPSeasonBuilder.createDefaultDailyMissions(),
    weekly: BPSeasonBuilder.createDefaultWeeklyMissions(),
  );
}


void _setupGacha() {
  final gacha = GetIt.I<GachaManager>();

  gacha.registerPool(GachaPool(
    id: 'standard_pool',
    nameKr: '스탠다드 뽑기',
    items: [
      // N (50%)
      ...List.generate(20, (i) => GachaItem(
        id: 'n_item_$i',
        nameKr: '일반 아이템 $i',
        rarity: GachaRarity.normal,
      )),

      // R (35%)
      ...List.generate(10, (i) => GachaItem(
        id: 'r_item_$i',
        nameKr: '레어 아이템 $i',
        rarity: GachaRarity.rare,
      )),

      // SR (12%)
      ...List.generate(5, (i) => GachaItem(
        id: 'sr_item_$i',
        nameKr: '슈퍼레어 아이템 $i',
        rarity: GachaRarity.superRare,
      )),

      // SSR (2.7%)
      const GachaItem(
        id: 'ssr_item_1',
        nameKr: '울트라레어 아이템 1',
        rarity: GachaRarity.ultraRare,
      ),

      // UR (0.3%)
      const GachaItem(
        id: 'ur_item_1',
        nameKr: '레전더리 아이템 1',
        rarity: GachaRarity.legendary,
      ),
    ],
  ));
}
