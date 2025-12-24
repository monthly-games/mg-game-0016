import 'package:flutter/material.dart';
import '../models/level_data.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';

class StageResultScreen extends StatelessWidget {
  final bool victory;
  final Stage stage;
  final Reward? earnedReward;
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  const StageResultScreen({
    super.key,
    required this.victory,
    required this.stage,
    this.earnedReward,
    required this.onContinue,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: victory ? AppColors.primary : Colors.red,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                victory ? 'VICTORY' : 'DEFEAT',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: victory ? AppColors.primary : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              if (victory && earnedReward != null) ...[
                const Text(
                  'Rewards Obtained:',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                _buildRewardRow(),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onContinue, // Goes back to map or next stage
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(victory ? 'Continue' : 'Return'),
                  ),
                  if (!victory)
                    TextButton(onPressed: onRetry, child: const Text('Retry')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (earnedReward!.gold > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.yellow,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  '${earnedReward!.gold}',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        if (earnedReward!.crystals > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Icon(Icons.diamond, color: Colors.cyan, size: 32),
                const SizedBox(height: 4),
                Text(
                  '${earnedReward!.crystals}',
                  style: const TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
