import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mario_game/constants/globals.dart';
import 'package:mario_game/objects/blocks/game_block.dart';
import 'package:mario_game/constants/animation_configs.dart';
import 'package:mario_game/games/super_mario_bros_game.dart';

class BrickBlock extends GameBlock with HasGameRef<SuperMarioBrosGame> {
  BrickBlock({required Vector2 position, required bool shouldCrumble})
    : super(
        animation: AnimationConfigs.block.brickBlockIdle(),
        position: position,
        shouldCrumble: shouldCrumble,
      );

  @override
  void hit() {
    if (shouldCrumble) {
      FlameAudio.play(Globals.breakBlockSFX);
      animation = AnimationConfigs.block.brickBlockHit();
    }

    super.hit();
  }
}
