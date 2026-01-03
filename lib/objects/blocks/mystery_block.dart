import 'package:flame/components.dart';
import 'package:mario_game/objects/blocks/game_block.dart';
import 'package:mario_game/constants/animation_configs.dart';
import 'package:mario_game/games/super_mario_bros_game.dart';

class MysteryBlock extends GameBlock with HasGameRef<SuperMarioBrosGame> {
  bool _hit = false;

  MysteryBlock({required Vector2 position})
    : super(
        animation: AnimationConfigs.block.mysteryBlockIdle(),
        position: position,
        shouldCrumble: false,
      );

  @override
  void hit() {
    if (!_hit) {
      _hit = true;

      // Updated to empty block animation.
      animation = AnimationConfigs.block.mysteryBlockHit();
    }

    super.hit();
  }
}
