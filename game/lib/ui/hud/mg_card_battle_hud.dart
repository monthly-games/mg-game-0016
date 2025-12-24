import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/ui/typography/mg_text_styles.dart';
import 'package:mg_common_game/core/ui/widgets/buttons/mg_icon_button.dart';
import 'package:mg_common_game/core/ui/widgets/progress/mg_linear_progress.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(MGSpacing.sm),
        child: Column(
          children: [
            // 상단 HUD
            Row(
              children: [
                // 왼쪽: 스테이지/턴 정보
                _buildTurnInfo(),
                const Spacer(),
                // 오른쪽: 일시정지
                if (onPause != null)
                  MGIconButton(
                    icon: Icons.pause,
                    onPressed: onPause!,
                    size: MGIconButtonSize.small,
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
      padding: EdgeInsets.symmetric(
        horizontal: MGSpacing.md,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: MGColors.surface.withOpacity(0.85),
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
                color: Colors.white,
              ),
            ),
            SizedBox(width: MGSpacing.sm),
            Container(
              width: 1,
              height: 20,
              color: MGColors.border,
            ),
            SizedBox(width: MGSpacing.sm),
          ],
          Icon(Icons.refresh, color: MGColors.primaryAction, size: 18),
          SizedBox(width: MGSpacing.xxs),
          Text(
            'Turn $turn',
            style: MGTextStyles.buttonMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardCounts() {
    return Container(
      padding: EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: MGColors.surface.withOpacity(0.85),
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
            color: Colors.blue,
            label: 'Deck',
          ),
          SizedBox(width: MGSpacing.md),
          // 패
          _buildCardCounter(
            icon: Icons.style,
            count: handCount,
            color: Colors.green,
            label: 'Hand',
          ),
          SizedBox(width: MGSpacing.md),
          // 무덤
          _buildCardCounter(
            icon: Icons.delete_outline,
            count: discardCount,
            color: Colors.grey,
            label: 'Discard',
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
        SizedBox(height: MGSpacing.xxs),
        Text(
          count.toString(),
          style: MGTextStyles.buttonMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildManaDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MGSpacing.lg,
        vertical: MGSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.8),
            Colors.purple.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(MGSpacing.md),
        border: Border.all(color: Colors.cyan, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
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
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                isFilled ? Icons.diamond : Icons.diamond_outlined,
                color: isFilled ? Colors.cyan : Colors.cyan.withOpacity(0.3),
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
        padding: EdgeInsets.symmetric(
          horizontal: MGSpacing.lg,
          vertical: MGSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MGColors.primaryAction,
              MGColors.primaryAction.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(MGSpacing.sm),
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: [
            BoxShadow(
              color: MGColors.primaryAction.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.skip_next, color: Colors.white, size: 20),
            SizedBox(width: MGSpacing.xs),
            Text(
              'END TURN',
              style: MGTextStyles.buttonMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
