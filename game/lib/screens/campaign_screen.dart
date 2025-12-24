import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import '../features/campaign/campaign_manager.dart';
import '../models/level_data.dart';
import 'battle_screen.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campaign')),
      body: Consumer<CampaignManager>(
        builder: (context, manager, child) {
          if (manager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: manager.chapters.length,
            itemBuilder: (context, index) {
              final chapter = manager.chapters[index];
              return _buildChapter(context, chapter, manager);
            },
          );
        },
      ),
    );
  }

  Widget _buildChapter(
    BuildContext context,
    Chapter chapter,
    CampaignManager manager,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            chapter.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        ...chapter.stages.map(
          (stage) => _buildStageItem(context, stage, manager),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildStageItem(
    BuildContext context,
    Stage stage,
    CampaignManager manager,
  ) {
    final bool isUnlocked = manager.isStageUnlocked(stage.id);

    return ListTile(
      enabled: isUnlocked,
      leading: Icon(
        isUnlocked ? Icons.location_on : Icons.lock,
        color: isUnlocked ? AppColors.primary : Colors.grey,
      ),
      title: Text(stage.name),
      subtitle: Text(stage.description),
      trailing: isUnlocked
          ? ElevatedButton(
              onPressed: () => _startStage(context, stage),
              child: const Text('Battle'),
            )
          : const Text('Locked', style: TextStyle(color: Colors.grey)),
    );
  }

  void _startStage(BuildContext context, Stage stage) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BattleScreen(stage: stage)),
    );
  }
}
