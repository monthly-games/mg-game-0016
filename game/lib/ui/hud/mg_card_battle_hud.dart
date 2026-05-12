import 'package:flutter/material.dart';
import 'package:mg_common_game/mg_common_game.dart';

/// MG-0016 Card Battle HUD.
class MGCardBattleHud extends StatelessWidget {
  const MGCardBattleHud({
    super.key,
    required this.turn,
    required this.mana,
    required this.maxMana,
    required this.deckCount,
    required this.handCount,
    required this.discardCount,
    this.stageName,
    this.onPause,
    this.onEndTurn,
    this.onDailyHub,
    this.onGuildWar,
    this.onTournament,
    this.onSeasonalEvent,
  });

  final int turn;
  final int mana;
  final int maxMana;
  final int deckCount;
  final int handCount;
  final int discardCount;
  final String? stageName;
  final VoidCallback? onPause;
  final VoidCallback? onEndTurn;
  final VoidCallback? onDailyHub;
  final VoidCallback? onGuildWar;
  final VoidCallback? onTournament;
  final VoidCallback? onSeasonalEvent;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(MGSpacing.sm),
        child: Column(
          children: [
            Row(
              children: [
                _StatusChip(
                  icon: Icons.flag,
                  label: stageName ?? 'Battle',
                  value: 'Turn $turn',
                ),
                const Spacer(),
                _IconAction(icon: Icons.calendar_today, onPressed: onDailyHub),
                _IconAction(icon: Icons.shield, onPressed: onGuildWar),
                _IconAction(icon: Icons.emoji_events, onPressed: onTournament),
                _IconAction(icon: Icons.celebration, onPressed: onSeasonalEvent),
                _IconAction(icon: Icons.pause, onPressed: onPause),
              ],
            ),
            const SizedBox(height: MGSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _StatusChip(
                    icon: Icons.bolt,
                    label: 'Mana',
                    value: '$mana/$maxMana',
                  ),
                ),
                const SizedBox(width: MGSpacing.sm),
                Expanded(
                  child: _StatusChip(
                    icon: Icons.layers,
                    label: 'Deck',
                    value: '$deckCount',
                  ),
                ),
                const SizedBox(width: MGSpacing.sm),
                Expanded(
                  child: _StatusChip(
                    icon: Icons.style,
                    label: 'Hand',
                    value: '$handCount',
                  ),
                ),
                const SizedBox(width: MGSpacing.sm),
                Expanded(
                  child: _StatusChip(
                    icon: Icons.delete_outline,
                    label: 'Discard',
                    value: '$discardCount',
                  ),
                ),
              ],
            ),
            if (onEndTurn != null) ...[
              const SizedBox(height: MGSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onEndTurn,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('End Turn'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: Icon(icon),
      color: MGColors.textHighEmphasis,
      onPressed: onPressed,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: MGColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: MGColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: MGColors.primaryAction, size: 18),
          const SizedBox(width: MGSpacing.xs),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: MGTextStyles.label),
                Text(value, style: MGTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
