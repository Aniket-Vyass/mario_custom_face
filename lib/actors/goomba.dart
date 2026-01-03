import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:mario_game/actors/mario.dart';
import 'package:mario_game/constants/animation_configs.dart';
import 'package:mario_game/constants/globals.dart';
import 'package:mario_game/games/super_mario_bros_game.dart';

class Goomba extends SpriteAnimationComponent
    with HasGameReference<SuperMarioBrosGame>, CollisionCallbacks {
  final double _speed = 50;

  Goomba({required Vector2 position})
    : super(
        position: Vector2(position.x, position.y - 15),
        size: Vector2(Globals.tileSize, Globals.tileSize),
        anchor: Anchor.topCenter,
        animation: AnimationConfigs.goomba.walking(),
      ) {
    Vector2 startPosition = Vector2(
      position.x,
      position.y - 15,
    ); // Store the adjusted starting position

    Vector2 targetPosition = Vector2(
      //ALTERNATE IDEA: Now that you have an end/target position you can make the goombas move to the rightmost and when goomba reaches levelbounds it can disappear
      position.x,
      position.y - 15,
    ); //position of goomba at X-axis

    // Goomba will move 50 pixels to the left and right.
    targetPosition.x -= 50;

    final SequenceEffect effect = SequenceEffect(
      [
        MoveToEffect(targetPosition, EffectController(speed: _speed)),
        MoveToEffect(startPosition, EffectController(speed: _speed)),
      ],
      infinite: true,
      alternate: true,
    );

    add(effect);

    add(CircleHitbox());
  }

  @override
  void onCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) async {
    if (other is Mario) {
      if (other.velocity.y > 0 && other.position.y < position.y) {
        //if (!other.isOnGround) {
        other.jump();

        animation = AnimationConfigs.goomba.dead();

        position.y += 0.5;

        // Display defeated Goomba for 0.5 seconds.
        await Future.delayed(const Duration(milliseconds: 500));

        // Remove dead Goomba.
        removeFromParent();
      }
    }

    super.onCollision(intersectionPoints, other);
  }
}
