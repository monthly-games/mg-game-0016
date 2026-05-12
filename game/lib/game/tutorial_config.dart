import 'package:mg_common_game/systems/tutorial/tutorial.dart';

/// Tutorial configuration for MG-0016: Deckbuilding Heroes.
///
/// Placeholder tutorial steps -- replace with localized strings
/// and add targetSelector for highlight positioning in production.
const kOnboardingTutorial = TutorialConfig(
  id: 'onboarding',
  name: 'Deckbuilding Heroes Tutorial',
  steps: [
    TutorialStep(
      id: 'deck',
      title: '카드를 뽑으세요',
      description: '턴 시작 시 덱에서 카드를 뽑습니다.',
    ),
    TutorialStep(
      id: 'field',
      title: '카드를 사용하세요',
      description: '카드를 드래그하여 필드에 놓으면 효과가 발동됩니다.',
    ),
    TutorialStep(
      id: 'end_turn',
      title: '턴을 종료하세요',
      description: '행동을 마치면 턴 종료 버튼을 누르세요.',
    ),
    TutorialStep(
      id: 'deck_builder',
      title: '덱을 구성하세요',
      description: '승리 후 새로운 카드로 덱을 강화하세요.',
    ),
  
  ],
  skippable: true,
);
