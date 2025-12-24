import 'package:flutter/material.dart';
import '../models/battle_state.dart';
import '../models/hero.dart';
import '../models/level_data.dart';
import '../logic/battle_engine.dart';
import '../data/mock_data.dart';
import '../models/battle_event.dart';
import 'widgets/floating_text.dart';

import 'package:provider/provider.dart';
import '../features/cards/card_collection.dart';
import '../features/campaign/campaign_manager.dart';
import 'stage_result_screen.dart';
import '../features/meta/quest_manager.dart';
import '../models/quest.dart';

class BattleScreen extends StatefulWidget {
  final Stage? stage;
  const BattleScreen({super.key, this.stage});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late BattleEngine _engine;
  late BattleState _state;
  final ScrollController _logScrollController = ScrollController();
  bool _battleEnded = false;

  @override
  void initState() {
    super.initState();
    _engine = BattleEngine();

    // Defer state initialization to build or post-frame since we need context for Provider
    // But initState happens before context is fully usable for inherited widgets sometimes?
    // Actually Provider.of(context, listen: false) works in initState if listen is false.
    // However, safest is to do it in didChangeDependencies or build.
    // Let's do it in didChangeDependencies just once.
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final deck = Provider.of<CardCollection>(
        context,
        listen: false,
      ).getDeckObject();
      // Use stage enemy if available, otherwise mock
      final enemy = widget.stage?.enemy ?? MockData.enemyHero;

      _state = _engine.initializeBattle(
        player: MockData.playerHero,
        enemy: enemy,
        deck: deck,
      );
      _initialized = true;
    }
  }

  final List<Widget> _floatingWidgets = [];

  void _addFloatingText(String text, Color color, bool isPlayerTarget) {
    // Position: If target is player (bottom), show near bottom.
    // If target is enemy (top), show near top.
    double top = isPlayerTarget
        ? MediaQuery.of(context).size.height * 0.6
        : MediaQuery.of(context).size.height * 0.2;
    double left =
        MediaQuery.of(context).size.width * 0.4 +
        (DateTime.now().millisecond % 50); // Minor random jitter

    ValueKey key = ValueKey(DateTime.now().toIso8601String());

    setState(() {
      _floatingWidgets.add(
        Positioned(
          key: key,
          top: top,
          left: left,
          child: FloatingText(
            text: text,
            color: color,
            onComplete: () {
              if (mounted) {
                setState(() {
                  _floatingWidgets.removeWhere((w) => w.key == key);
                });
              }
            },
          ),
        ),
      );
    });
  }

  void _nextTurn() {
    if (_battleEnded) return;

    final nextState = _engine.nextTurn(_state);

    // Process Events for UI FX
    for (var event in nextState.lastTurnEvents) {
      bool isPlayerTarget = event.targetId == 'player';
      Color color = Colors.white;
      String text = event.value.toString();

      if (event.type == BattleEventType.damage) {
        color = Colors.red;
        text = "-${event.value}";
      } else if (event.type == BattleEventType.heal) {
        color = Colors.green;
        text = "+${event.value}";

        _addFloatingText(text, color, isPlayerTarget);

        // TODO: Play SFX
        // if (event.type == BattleEventType.damage) AudioManager.playSfx('hit');
      }

      // _addFloatingText(text, color, isPlayerTarget); // This line was moved inside the if/else if blocks
    }

    setState(() {
      _state = nextState;
    });

    // Check end condition
    if (_state.phase == BattlePhase.end) {
      _battleEnded = true;
      _onBattleEnd();
    }

    // Scroll to bottom of logs (omitted for brevity if unchanged, but keeping it safe)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ...

  void _onBattleEnd() {
    // Determine winner
    bool win = _state.player.stats.hp > 0 && _state.enemy.stats.hp <= 0;
    Reward? reward;

    final questManager = Provider.of<QuestManager>(context, listen: false);

    // Update Quests
    if (win) {
      questManager.updateProgress(QuestType.winBattles, 1);
    }
    questManager.updateProgress(QuestType.playCards, _state.cardsPlayed);

    if (win && widget.stage != null) {
      final manager = Provider.of<CampaignManager>(context, listen: false);
      manager.completeStage(widget.stage!, true);
      reward = widget.stage!.firstClearReward ?? widget.stage!.repeatReward;

      // Update gold/earn quests?
      // Not yet implemented in QuestManager updateProgress for 'earnGold' from rewards directly here,
      // but maybe lazily done or explicitly calling it if we knew the amount.
      // For now just Cards and Wins.
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StageResultScreen(
            victory: win,
            stage:
                widget.stage ??
                const Stage(
                  id: '0',
                  name: 'Practice',
                  description: '',
                  enemy: MockData.enemyHero,
                ),
            earnedReward: reward,
            onContinue: () => Navigator.pop(context),
            onRetry: () => Navigator.pop(context),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.stage?.name ?? 'Battle!')),
      body: Stack(
        children: [
          Column(
            children: [
              // Enemy Area
              _buildHeroStats(_state.enemy, Colors.red[100]!),

              Expanded(
                child: Container(
                  color: Colors.grey[200],
                  child: ListView.builder(
                    controller: _logScrollController,
                    itemCount: _state.battleLog.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Text(_state.battleLog[index]),
                      );
                    },
                  ),
                ),
              ),

              // Player Area
              _buildHeroStats(_state.player, Colors.blue[100]!),

              // Control Area
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!_battleEnded)
                      ElevatedButton.icon(
                        onPressed: _nextTurn,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Next Turn'),
                      )
                    else
                      const Text("Battle Ended"),
                  ],
                ),
              ),
            ],
          ),
          // Floating Text Overlay
          ..._floatingWidgets,
        ],
      ),
    );
  }

  Widget _buildHeroStats(Hero hero, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: color,
      child: Column(
        children: [
          Text(
            hero.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: hero.stats.hp / hero.stats.maxHp,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(
              hero.stats.hp > hero.stats.maxHp * 0.3
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text("HP: ${hero.stats.hp} / ${hero.stats.maxHp}"),
        ],
      ),
    );
  }
}
