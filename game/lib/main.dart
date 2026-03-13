import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/screens/seasonal_event_screen.dart';
import 'package:mg_common_game/core/ui/screens/tournament_screen.dart';
import 'package:mg_common_game/core/ui/screens/guild_war_screen.dart';
import 'package:mg_common_game/systems/events/seasonal_content_manager.dart';
import 'package:mg_common_game/systems/competitive/tournament_manager.dart';
import 'package:mg_common_game/systems/social/guild_war_manager.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/ui/screens/daily_hub_screen.dart';
import 'package:mg_common_game/systems/retention/daily_challenge_manager.dart';
import 'package:mg_common_game/systems/retention/streak_manager.dart';
import 'package:mg_common_game/systems/retention/login_rewards_manager.dart';
import 'package:mg_common_game/systems/gacha/gacha_pool.dart';
import 'package:mg_common_game/systems/gacha/gacha_manager.dart';
import 'package:mg_common_game/systems/battlepass/battlepass_config.dart';
import 'package:mg_common_game/systems/battlepass/battlepass_manager.dart';
import 'package:mg_common_game/systems/progression/achievement_manager.dart';
import 'package:mg_common_game/systems/quests/daily_quest.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/systems/collection/collection_manager.dart';
import 'package:mg_common_game/systems/collection/collection.dart';
import 'package:mg_common_game/systems/collection/collection_item.dart';
import 'package:mg_common_game/systems/collection/collection_reward.dart';
import 'package:provider/provider.dart';
import 'features/cards/card_collection.dart';

import 'screens/deck_builder_screen.dart';
import 'screens/battle_screen.dart';
import 'screens/campaign_screen.dart';
import 'features/campaign/campaign_manager.dart';
import 'features/meta/quest_manager.dart';
import 'screens/quest_screen.dart';
import 'data/mock_data.dart';
import 'features/gacha/gacha_adapter.dart';
import 'models/card.dart';
import 'screens/battlepass_screen.dart';
import 'screens/gacha_screen.dart';
import 'screens/daily_quest_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/collection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  _registerCollections();
  try {
    await GetIt.I<AudioManager>().initialize();
  } catch (e) {
    debugPrint("Audio init failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CardCollection()),
        ChangeNotifierProvider<mg_systems.CollectionManager>.value(
          value: GetIt.I<mg_systems.CollectionManager>(),
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
  if (!GetIt.I.isRegistered<AudioManager>()) {
    GetIt.I.registerSingleton<AudioManager>(AudioManager());
  }
  if (!GetIt.I.isRegistered<CollectionManager>()) {
    GetIt.I.registerSingleton<CollectionManager>(
  // DailyQuest 시스템
  GetIt.I.registerSingleton(DailyQuestManager());
  // Achievement 시스템
  GetIt.I.registerSingleton(AchievementManager());
  // BattlePass 시스템
  GetIt.I.registerSingleton(BattlePassManager());
  // Gacha 시스템
  GetIt.I.registerSingleton(GachaManager());
  // ── Retention Systems for DailyHub ────────────────────────
  if (!GetIt.I.isRegistered<LoginRewardsManager>()) {
    GetIt.I.registerSingleton(LoginRewardsManager());
  }
  if (!GetIt.I.isRegistered<StreakManager>()) {
    GetIt.I.registerSingleton(StreakManager());
  }
  if (!GetIt.I.isRegistered<DailyChallengeManager>()) {
    GetIt.I.registerSingleton(DailyChallengeManager());
}
  // ── P3 Engine Systems ─────────────────────────────────────
  if (!GetIt.I.isRegistered<GuildWarManager>()) {
    GetIt.I.registerSingleton(GuildWarManager());
  }
  if (!GetIt.I.isRegistered<TournamentManager>()) {
    GetIt.I.registerSingleton(TournamentManager());
  }
  if (!GetIt.I.isRegistered<SeasonalContentManager>()) {
    GetIt.I.registerSingleton(SeasonalContentManager());
  }
  _setupGacha();
  _setupBattlePass();
  _registerAchievements();
  _registerDailyQuests();
      CollectionManager(),
    );
  }
}

void _registerCollections() {
  final collectionManager = GetIt.I<mg_systems.CollectionManager>();

  // Register card collection (7 cards from mock_data)
  final cardItems = [
    mg_systems.CollectionItem(
      id: 'c1',
      name: 'Strike',
      description: 'Deal 10 damage',
      rarity: mg_systems.CollectionRarity.common,
    ),
    mg_systems.CollectionItem(
      id: 'c2',
      name: 'Defend',
      description: 'Gain 5 block',
      rarity: mg_systems.CollectionRarity.common,
    ),
    mg_systems.CollectionItem(
      id: 'c3',
      name: 'Heavy Hit',
      description: 'Deal 25 damage',
      rarity: mg_systems.CollectionRarity.rare,
    ),
    mg_systems.CollectionItem(
      id: 'c4',
      name: 'Quick Slash',
      description: 'Deal 6 damage',
      rarity: mg_systems.CollectionRarity.common,
    ),
    mg_systems.CollectionItem(
      id: 'c5',
      name: 'Holy Light',
      description: 'Heal 20 HP',
      rarity: mg_systems.CollectionRarity.rare,
    ),
    mg_systems.CollectionItem(
      id: 'c6',
      name: 'Fireball',
      description: 'Deal 18 damage',
      rarity: mg_systems.CollectionRarity.rare,
    ),
    mg_systems.CollectionItem(
      id: 'c7',
      name: 'Meteor',
      description: 'Deal 50 damage',
      rarity: mg_systems.CollectionRarity.legendary,
    ),
  ];

  final cardCollection = mg_systems.Collection(
    id: 'card_collection',
    name: 'Card Collection',
    description: 'Collect all battle cards',
    items: cardItems,
    category: 'cards',
    milestoneRewards: {
      25: mg_systems.CollectionReward(
        id: 'card_25',
        name: '25% Reward',
        description: 'Unlocked 25% of cards',
      ),
      50: mg_systems.CollectionReward(
        id: 'card_50',
        name: '50% Reward',
        description: 'Unlocked 50% of cards',
      ),
      75: mg_systems.CollectionReward(
        id: 'card_75',
        name: '75% Reward',
        description: 'Unlocked 75% of cards',
      ),
    },
    completionReward: mg_systems.CollectionReward(
      id: 'card_complete',
      name: 'Complete Collection',
      description: 'Unlocked all cards!',
    ),
  );

  // Register gacha collection (20 items from gacha_adapter)
  final gachaItems = [
    // UR (2 items)
    mg_systems.CollectionItem(
      id: 'ur_cardbattle_001',
      name: '전설의 BattleCard',
      description: 'Legendary battle card',
      rarity: mg_systems.CollectionRarity.mythic,
    ),
    mg_systems.CollectionItem(
      id: 'ur_cardbattle_002',
      name: '신화의 BattleCard',
      description: 'Mythic battle card',
      rarity: mg_systems.CollectionRarity.mythic,
    ),
    // SSR (3 items)
    mg_systems.CollectionItem(
      id: 'ssr_cardbattle_001',
      name: '영웅의 BattleCard',
      description: 'Hero battle card',
      rarity: mg_systems.CollectionRarity.legendary,
    ),
    mg_systems.CollectionItem(
      id: 'ssr_cardbattle_002',
      name: '고대의 BattleCard',
      description: 'Ancient battle card',
      rarity: mg_systems.CollectionRarity.legendary,
    ),
    mg_systems.CollectionItem(
      id: 'ssr_cardbattle_003',
      name: '황금의 BattleCard',
      description: 'Golden battle card',
      rarity: mg_systems.CollectionRarity.legendary,
    ),
    // SR (4 items)
    mg_systems.CollectionItem(
      id: 'sr_cardbattle_001',
      name: '희귀한 BattleCard A',
      description: 'Rare battle card A',
      rarity: mg_systems.CollectionRarity.epic,
    ),
    mg_systems.CollectionItem(
      id: 'sr_cardbattle_002',
      name: '희귀한 BattleCard B',
      description: 'Rare battle card B',
      rarity: mg_systems.CollectionRarity.epic,
    ),
    mg_systems.CollectionItem(
      id: 'sr_cardbattle_003',
      name: '희귀한 BattleCard C',
      description: 'Rare battle card C',
      rarity: mg_systems.CollectionRarity.epic,
    ),
    mg_systems.CollectionItem(
      id: 'sr_cardbattle_004',
      name: '희귀한 BattleCard D',
      description: 'Rare battle card D',
      rarity: mg_systems.CollectionRarity.epic,
    ),
    // R (5 items)
    mg_systems.CollectionItem(
      id: 'r_cardbattle_001',
      name: '우수한 BattleCard A',
      description: 'Uncommon battle card A',
      rarity: mg_systems.CollectionRarity.rare,
    ),
    mg_systems.CollectionItem(
      id: 'r_cardbattle_002',
      name: '우수한 BattleCard B',
      description: 'Uncommon battle card B',
      rarity: mg_systems.CollectionRarity.rare,
    ),
    mg_systems.CollectionItem(
      id: 'r_cardbattle_003',
      name: '우수한 BattleCard C',
      description: 'Uncommon battle card C',
      rarity: mg_systems.CollectionRarity.rare,
    ),
    mg_systems.CollectionItem(
      id: 'r_cardbattle_004',
      name: '우수한 BattleCard D',
      description: 'Uncommon battle card D',
      rarity: mg_systems.CollectionRarity.rare,
    ),
    mg_systems.CollectionItem(
      id: 'r_cardbattle_005',
      name: '우수한 BattleCard E',
      description: 'Uncommon battle card E',
      rarity: mg_systems.CollectionRarity.rare,
    ),
    // N (6 items)
    mg_systems.CollectionItem(
      id: 'n_cardbattle_001',
      name: '일반 BattleCard A',
      description: 'Common battle card A',
      rarity: mg_systems.CollectionRarity.common,
    ),
    mg_systems.CollectionItem(
      id: 'n_cardbattle_002',
      name: '일반 BattleCard B',
      description: 'Common battle card B',
      rarity: mg_systems.CollectionRarity.common,
    ),
    mg_systems.CollectionItem(
      id: 'n_cardbattle_003',
      name: '일반 BattleCard C',
      description: 'Common battle card C',
      rarity: mg_systems.CollectionRarity.common,
    ),
    mg_systems.CollectionItem(
      id: 'n_cardbattle_004',
      name: '일반 BattleCard D',
      description: 'Common battle card D',
      rarity: mg_systems.CollectionRarity.common,
    ),
    mg_systems.CollectionItem(
      id: 'n_cardbattle_005',
      name: '일반 BattleCard E',
      description: 'Common battle card E',
      rarity: mg_systems.CollectionRarity.common,
    ),
    mg_systems.CollectionItem(
      id: 'n_cardbattle_006',
      name: '일반 BattleCard F',
      description: 'Common battle card F',
      rarity: mg_systems.CollectionRarity.common,
    ),
  ];

  final gachaCollection = mg_systems.Collection(
    id: 'gacha_collection',
    name: 'Gacha Collection',
    description: 'Collect all gacha cards',
    items: gachaItems,
    category: 'gacha',
    milestoneRewards: {
      25: mg_systems.CollectionReward(
        id: 'gacha_25',
        name: '25% Reward',
        description: 'Unlocked 25% of gacha cards',
      ),
      50: mg_systems.CollectionReward(
        id: 'gacha_50',
        name: '50% Reward',
        description: 'Unlocked 50% of gacha cards',
      ),
      75: mg_systems.CollectionReward(
        id: 'gacha_75',
        name: '75% Reward',
        description: 'Unlocked 75% of gacha cards',
      ),
    },
    completionReward: mg_systems.CollectionReward(
      id: 'gacha_complete',
      name: 'Complete Gacha Collection',
      description: 'Unlocked all gacha cards!',
    ),
  );

  // Register both collections
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
        '/collections': (context) => const CollectionsScreen(),
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
      GachaItem(
        id: 'ssr_item_1',
        nameKr: '울트라레어 아이템 1',
        rarity: GachaRarity.ultraRare,
      ),

      // UR (0.3%)
      GachaItem(
        id: 'ur_item_1',
        nameKr: '레전더리 아이템 1',
        rarity: GachaRarity.legendary,
      ),
    ],
  ));
}
