import 'package:equatable/equatable.dart';
import 'quest.dart';

class PlayerData extends Equatable {
  final Map<String, int> ownedCards; // CardId -> Count
  final List<String> currentDeck; // List of CardIds
  final int gold;
  final int crystals;
  final int cardFragments;
  final List<String> unlockedStageIds;
  final Map<String, int> cardLevels; // CardId -> Level
  final Map<String, int> stats;
  final List<Quest> activeQuests;
  final List<String> completedAchievements;

  const PlayerData({
    required this.ownedCards,
    required this.currentDeck,
    this.gold = 0,
    this.crystals = 0,
    this.cardFragments = 0,
    this.unlockedStageIds = const ['1-1'],
    this.cardLevels = const {},
    this.stats = const {},
    this.activeQuests = const [],
    this.completedAchievements = const [],
  });

  factory PlayerData.initial() {
    return const PlayerData(
      ownedCards: {},
      currentDeck: [],
      gold: 100,
      crystals: 0,
      unlockedStageIds: ['1-1'],
      cardLevels: {},
      stats: {},
      activeQuests: [],
      completedAchievements: [],
    );
  }

  PlayerData copyWith({
    Map<String, int>? ownedCards,
    List<String>? currentDeck,
    int? gold,
    int? crystals,
    int? cardFragments,
    List<String>? unlockedStageIds,
    Map<String, int>? cardLevels,
    Map<String, int>? stats,
    List<Quest>? activeQuests,
    List<String>? completedAchievements,
  }) {
    return PlayerData(
      ownedCards: ownedCards ?? this.ownedCards,
      currentDeck: currentDeck ?? this.currentDeck,
      gold: gold ?? this.gold,
      crystals: crystals ?? this.crystals,
      cardFragments: cardFragments ?? this.cardFragments,
      unlockedStageIds: unlockedStageIds ?? this.unlockedStageIds,
      cardLevels: cardLevels ?? this.cardLevels,
      stats: stats ?? this.stats,
      activeQuests: activeQuests ?? this.activeQuests,
      completedAchievements:
          completedAchievements ?? this.completedAchievements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownedCards': ownedCards,
      'currentDeck': currentDeck,
      'gold': gold,
      'crystals': crystals,
      'cardFragments': cardFragments,
      'unlockedStageIds': unlockedStageIds,
      'cardLevels': cardLevels,
      'stats': stats,
      'activeQuests': activeQuests.map((q) => q.toJson()).toList(),
      'completedAchievements': completedAchievements,
    };
  }

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      ownedCards: Map<String, int>.from(json['ownedCards'] ?? {}),
      currentDeck: List<String>.from(json['currentDeck'] ?? []),
      gold: json['gold'] as int? ?? 0,
      crystals: json['crystals'] as int? ?? 0,
      cardFragments: json['cardFragments'] as int? ?? 0,
      unlockedStageIds: List<String>.from(json['unlockedStageIds'] ?? ['1-1']),
      cardLevels: Map<String, int>.from(json['cardLevels'] ?? {}),
      stats: Map<String, int>.from(json['stats'] ?? {}),
      activeQuests:
          (json['activeQuests'] as List<dynamic>?)
              ?.map((e) => Quest.fromJson(e))
              .toList() ??
          [],
      completedAchievements: List<String>.from(
        json['completedAchievements'] ?? [],
      ),
    );
  }

  @override
  List<Object?> get props => [
    ownedCards,
    currentDeck,
    gold,
    crystals,
    cardFragments,
    unlockedStageIds,
    cardLevels,
    stats,
    activeQuests,
    completedAchievements,
  ];
}
