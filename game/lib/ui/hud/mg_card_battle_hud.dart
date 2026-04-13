import 'package:mg_common_game/mg_common_game.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';import 'package:mg_common_game/l10n/localization.dart';


/// MG-0016 Card Battle HUD
/// 카드 배틀 게임용 HUD - 턴 정보, 덱/패/무덤 카운트, 마나 표시
class MGCardBattleHud extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(MGSpacing.sm),
        child: Column(
          children: [
            // 상단 HUD
            Row(
              children: [
                // 왼쪽: 스테이지/턴 정보
                _buildTurnInfo(),
                const Spacer(),
                // 오른쪽: 일시정지
                if (onGuildWar != null)
                  MGIconButton(
                    icon: Icons.shield,
                    onPressed: onGuildWar!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onTournament != null)
                  MGIconButton(
                    icon: Icons.emoji_events,
                    onPressed: onTournament!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onSeasonalEvent != null)
                  MGIconButton(
                    icon: Icons.celebration,
                    onPressed: onSeasonalEvent!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onDailyHub != null)
                  MGIconButton(
                    icon: Icons.calendar_today,
                    onPressed: onDailyHub!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onPause != null)
                  MGIconButton(
                    icon: Icons.pause,
                    onPressed: onPause!,
                    buttonSize: MGIconButtonSize.small,
                  ),
              ],
            ),
            const Spacer(),
            // 하단 HUD
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 왼쪽 하단: 덱/패/무덤 카운트
                _buildCardCounts(),
                // 중앙 하단: 마나
                _buildManaDisplay(),
                // 오른쪽 하단: 턴 종료 버튼
                if (onEndTurn != null) _buildEndTurnButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MGSpacing.md,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: MGColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: MGColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (stageName != null) ...[
            Text(
              stageName!,
              style: MGTextStyles.buttonMedium.copyWith(
                color: MGColors.textHighEmphasis,
              ),
            ),
            const SizedBox(width: MGSpacing.sm),
            Container(
              width: 1,
              height: 20,
              color: MGColors.border,
            ),
            const SizedBox(width: MGSpacing.sm),
          ],
          const Icon(Icons.refresh, color: MGColors.primaryAction, size: 18),
          const SizedBox(width: MGSpacing.xxs),
          Text(
            'Turn $turn',
            style: MGTextStyles.buttonMedium.copyWith(
              color: MGColors.textHighEmphasis,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardCounts() {
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
          // 덱
          _buildCardCounter(
            icon: Icons.layers,
            count: deckCount,
            color: MGColors.info,
            label: 'ui_general_deckbuilding_heroes'.tr,
          ),
          const SizedBox(width: MGSpacing.md),
          // 패
          _buildCardCounter(
            icon: Icons.style,
            count: handCount,
            color: MGColors.success,
            label: 'progress_'.tr핸들링_playerselectedvehiclebasestatshandling10,
          ),
          const SizedBox(width: MGSpacing.md),
          // 무덤
          _buildCardCounter(
            icon: Icons.delete_outline,
            count: discardCount,
            color: MGColors.common,
            label: 'progress_this_will_discard_your_current'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildCardCounter({
    required IconData icon,
    required int count,
    required Color color,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: MGSpacing.xxs),
        Text(
          count.toString(),
          style: MGTextStyles.buttonMedium.copyWith(
            color: MGColors.textHighEmphasis,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildManaDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MGSpacing.lg,
        vertical: MGSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MGColors.info.withValues(alpha: 0.8),
            Colors.purple.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(MGSpacing.md),
        border: Border.all(color: Colors.cyan, width: 2),
        boxShadow: [
          BoxShadow(
            color: MGColors.info.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 마나 아이콘들
          ...List.generate(maxMana, (index) {
            final bool isFilled = index < mana;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                isFilled ? Icons.diamond : Icons.diamond_outlined,
                color: isFilled ? Colors.cyan : Colors.cyan.withValues(alpha: 0.3),
                size: 24,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEndTurnButton() {
    return GestureDetector(
      onTap: onEndTurn,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MGSpacing.lg,
          vertical: MGSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MGColors.primaryAction,
              MGColors.primaryAction.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(MGSpacing.sm),
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: [
            BoxShadow(
              color: MGColors.primaryAction.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.skip_next, color: MGColors.textHighEmphasis, size: 20),
            const SizedBox(width: MGSpacing.xs),
            Text(
              'END TURN',
              style: MGTextStyles.buttonMedium.copyWith(
                color: MGColors.textHighEmphasis,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSpineCharacter() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withAlpha(150), width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 24, color: Colors.white),
            SizedBox(height: 2),
            Text(
              'Sniper',
              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

}
