import 'package:equatable/equatable.dart';
import 'hero.dart';
import 'card.dart';
import 'battle_event.dart';

enum BattlePhase { start, playerTurn, enemyTurn, end }

class BattleState extends Equatable {
  final Hero player;
  final Hero enemy;
  final List<Card> playerDeck; // Remaining cards in draw pile
  final List<Card> playerHand;
  final List<Card> playerDiscard;
  final BattlePhase phase;
  final int turnCount;
  final List<String> battleLog;
  final List<BattleEvent> lastTurnEvents;
  final int cardsPlayed;

  const BattleState({
    required this.player,
    required this.enemy,
    required this.playerDeck,
    required this.playerHand,
    required this.playerDiscard,
    this.phase = BattlePhase.start,
    this.turnCount = 1,
    this.battleLog = const [],
    this.lastTurnEvents = const [],
    this.cardsPlayed = 0,
  });

  BattleState copyWith({
    Hero? player,
    Hero? enemy,
    List<Card>? playerDeck,
    List<Card>? playerHand,
    List<Card>? playerDiscard,
    BattlePhase? phase,
    int? turnCount,
    List<String>? battleLog,
    List<BattleEvent>? lastTurnEvents,
    int? cardsPlayed,
  }) {
    return BattleState(
      player: player ?? this.player,
      enemy: enemy ?? this.enemy,
      playerDeck: playerDeck ?? this.playerDeck,
      playerHand: playerHand ?? this.playerHand,
      playerDiscard: playerDiscard ?? this.playerDiscard,
      phase: phase ?? this.phase,
      turnCount: turnCount ?? this.turnCount,
      battleLog: battleLog ?? this.battleLog,
      lastTurnEvents: lastTurnEvents ?? this.lastTurnEvents,
      cardsPlayed: cardsPlayed ?? this.cardsPlayed,
    );
  }

  @override
  List<Object?> get props => [
    player,
    enemy,
    playerDeck,
    playerHand,
    playerDiscard,
    phase,
    turnCount,
    battleLog,
    lastTurnEvents,
    cardsPlayed,
  ];
}
