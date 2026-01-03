import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:mario_game/constants/animation_configs.dart';
import 'package:mario_game/constants/globals.dart';
import 'package:mario_game/games/super_mario_bros_game.dart';
import 'package:mario_game/objects/platform.dart';

enum MarioAnimationState { idle, walking, jumping }

class Mario extends SpriteAnimationGroupComponent<MarioAnimationState>
    with CollisionCallbacks, KeyboardHandler, HasGameRef<SuperMarioBrosGame> {
  final double _gravity = 15;
  final Vector2 velocity = Vector2.zero(); //represent direction and speed

  final Vector2 _up = Vector2(0, -1);
  bool _jumpInput = false;
  bool isOnGround = false;
  bool _paused = false;

  static const double _minMoveSpeed = 125;
  static const double _maxMoveSpeed = _minMoveSpeed + 100;

  double _currentSpeed = _minMoveSpeed;

  bool isFacingRight = true;

  double _hAxisInput = 0;

  //👇_minClamp and _maxClamp are pretty much the _levelbounds that we specified, see line 25
  //basically
  late Vector2
  _minClamp; //minimun level coordinate that mario can go in a level
  late Vector2
  _maxClamp; //maximum level coordinates that mario can go in a level

  double _jumpSpeed = 400;

  Mario({required Vector2 position, required Rectangle levelBounds})
    : super(
        position: position,
        size: Vector2(Globals.tileSize, Globals.tileSize),
        anchor: Anchor.center,
      ) {
    debugMode = true;
    //we do size/2 because we need to account for
    _minClamp = levelBounds.topLeft + (size / 2);
    _maxClamp = levelBounds.bottomRight + (size / 2);

    add(CircleHitbox());
  }
  //The GAME LOOP this method would be called appx every 0.1 second
  @override
  void update(double dt) {
    super.update(dt);

    if (dt > 0.05) return;

    velocityUpdate();
    positionUpdate(dt);
    speedUpdate();
    facingDirectionUpdate();
    jumpUpdate();
    marioAnimationUpdate();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hAxisInput = 0;

    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.arrowLeft) ? -1 : 0;
    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.arrowRight) ? 1 : 0;
    _jumpInput = keysPressed.contains(LogicalKeyboardKey.space);

    void _pause() {
      FlameAudio.play(Globals.pauseSFX);

      _paused ? gameRef.resumeEngine() : gameRef.pauseEngine();

      _paused = !_paused;
    }

    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      _pause();
    }

    // ✅ Only set _jumpInput to true on key DOWN, not while held
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      _jumpInput = true;
    } else if (event is KeyUpEvent &&
        event.logicalKey == LogicalKeyboardKey.space) {
      _jumpInput = false;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void jumpUpdate() {
    if (_jumpInput && isOnGround) {
      jump();
      _jumpInput = false;
    }
  }

  void jump() {
    velocity.y -= _jumpSpeed;
    isOnGround = false;

    FlameAudio.play(Globals.jumpSmallSFX);
  }

  void speedUpdate() {
    if (_hAxisInput == 0) {
      _currentSpeed = _minMoveSpeed;
    } else {
      if (_currentSpeed <= _maxMoveSpeed) {
        _currentSpeed++;
      }
    }
  }

  void facingDirectionUpdate() {
    if (_hAxisInput > 0) {
      isFacingRight = true;
    } else {
      isFacingRight = false;
    }

    if ((_hAxisInput > 0 && scale.x < 0) || (_hAxisInput < 0 && scale.x > 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void velocityUpdate() {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpSpeed, 150);

    velocity.x = _hAxisInput * _currentSpeed;
  }

  void positionUpdate(double dt) {
    Vector2 distance = velocity * dt;
    position += distance;

    position.x = position.x.clamp(_minClamp.x, _maxClamp.x);
    position.y = position.y.clamp(_minClamp.y, _maxClamp.y);
  }

  void marioAnimationUpdate() {
    if (!isOnGround) {
      current = MarioAnimationState.jumping;
    } else if (_hAxisInput < 0 || _hAxisInput > 0) {
      current = MarioAnimationState.walking;
    } else {
      current = MarioAnimationState.idle;
    }
  }

  @override
  Future<void> onLoad() async {
    final SpriteAnimation idle = await AnimationConfigs.mario
        .idle(); //idle position me default rahega that's why pahle se load kar rahe hai
    final SpriteAnimation walking = await AnimationConfigs.mario.walking();
    final SpriteAnimation jumping = await AnimationConfigs.mario.jumping();

    //now we are gonna map each of the animation states from enum(idle, jump, walking) to their respective animations
    animations = {
      MarioAnimationState.idle: idle,
      MarioAnimationState.walking: walking,
      MarioAnimationState.jumping: jumping,
    };

    current = MarioAnimationState.idle;

    return super.onLoad();
  }

  //In this function we would know when mario collides with an object, more importantly which kind of object
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    //To determine if mario is hitting/colliding with a platform we would do this
    if (other is Platform) {
      if (intersectionPoints.length == 2) {
        platformPositionCheck(intersectionPoints);
      }
    }
  }

  //method below is called when mario collides with a platform. basically a collision check
  //this method is a safety method defined to check how deep in the mario circle has entered into the platform & push it back
  void platformPositionCheck(Set<Vector2> intersectionPoints) {
    final Vector2 mid =
        (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;

    final Vector2 collisionNormal = absoluteCenter - mid;
    double penetrationLength = (size.x / 2) - collisionNormal.length;
    collisionNormal.normalize();

    if (_up.dot(collisionNormal) > 0.9) {
      isOnGround = true;
    }

    position += collisionNormal.scaled(penetrationLength);
  }
}
