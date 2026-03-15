import 'package:mg_common_game/core/assets/asset_types.dart';

/// Spine 통합 플래그. `--dart-define=SPINE_ENABLED=true`로 활성화.
const kSpineEnabled = bool.fromEnvironment(
  'SPINE_ENABLED',
  defaultValue: false,
);

// ── Deck Warrior ─────────────────────────────────────────────

const kDeckWarriorMeta = SpineAssetMeta(
  key: 'deck_warrior',
  path: 'spine/characters/deck_warrior',
  atlasPath:
      'assets/spine/characters/deck_warrior/deck_warrior.atlas',
  skeletonPath:
      'assets/spine/characters/deck_warrior/deck_warrior.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Deck Sorcerer ────────────────────────────────────────────

const kDeckSorcererMeta = SpineAssetMeta(
  key: 'deck_sorcerer',
  path: 'spine/characters/deck_sorcerer',
  atlasPath:
      'assets/spine/characters/deck_sorcerer/deck_sorcerer.atlas',
  skeletonPath:
      'assets/spine/characters/deck_sorcerer/deck_sorcerer.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Deck Rogue ───────────────────────────────────────────────

const kDeckRogueMeta = SpineAssetMeta(
  key: 'deck_rogue',
  path: 'spine/characters/deck_rogue',
  atlasPath: 'assets/spine/characters/deck_rogue/deck_rogue.atlas',
  skeletonPath:
      'assets/spine/characters/deck_rogue/deck_rogue.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);
