import 'dart:io';
import 'dart:ui' as ui;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // ADD THIS LINE
import 'package:mario_game/constants/globals.dart';
import 'package:mario_game/games/super_mario_bros_game.dart';
import 'package:mario_game/objects/platform.dart';
import 'package:mario_game/utils/face_storage.dart';

enum MarioAnimationState { idle, walking, jumping }

class Mario extends PositionComponent
    with CollisionCallbacks, KeyboardHandler, HasGameRef<SuperMarioBrosGame> {
  final double _gravity = 15;
  final Vector2 velocity = Vector2.zero();

  final Vector2 _up = Vector2(0, -1);
  bool _jumpInput = false;
  bool isOnGround = false;
  bool _paused = false;

  static const double _minMoveSpeed = 125;
  static const double _maxMoveSpeed = _minMoveSpeed + 100;

  double _currentSpeed = _minMoveSpeed;

  bool isFacingRight = true;

  double _hAxisInput = 0;

  late Vector2 _minClamp;
  late Vector2 _maxClamp;

  double _jumpSpeed = 400;

  // Animation state
  MarioAnimationState _currentState = MarioAnimationState.idle;

  // Sprite components
  late SpriteComponent _headSprite;
  late SpriteComponent _bodySprite;

  // Body sprites for different states
  late Sprite _bodyIdle;
  late Sprite _bodyWalk;
  late Sprite _bodyJump;

  // Custom face
  bool _useCustomFace = false;
  Sprite? _customFaceSprite;

  // Walking animation timing
  double _walkAnimationTimer = 0;
  final double _walkAnimationSpeed = 0.15; // seconds per frame
  bool _showWalkFrame = false;

  Mario({required Vector2 position, required Rectangle levelBounds})
    : super(
        position: position,
        size: Vector2(Globals.tileSize, Globals.tileSize),
        anchor: Anchor.topCenter,
      ) {
    debugMode = true;
    _minClamp = levelBounds.topLeft;
    _maxClamp = levelBounds.bottomRight;

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (dt > 0.05) return;

    velocityUpdate();
    positionUpdate(dt);
    speedUpdate();
    facingDirectionUpdate();
    jumpUpdate();
    marioAnimationUpdate(dt);
    updateSpritePositions();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hAxisInput = 0;

    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.arrowLeft) ? -1 : 0;
    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.arrowRight) ? 1 : 0;

    void pauseGame() {
      FlameAudio.play(Globals.pauseSFX);
      _paused ? gameRef.resumeEngine() : gameRef.pauseEngine();
      _paused = !_paused;
    }

    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      pauseGame();
    }

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

  // Called from on-screen buttons
  void moveLeft() {
    _hAxisInput = -1;
  }

  void moveRight() {
    _hAxisInput = 1;
  }

  void stop() {
    _hAxisInput = 0;
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
    bool shouldFaceRight = _hAxisInput > 0;
    bool shouldFaceLeft = _hAxisInput < 0;

    if (shouldFaceRight && !isFacingRight) {
      isFacingRight = true;
      _headSprite.flipHorizontallyAroundCenter();
      _bodySprite.flipHorizontallyAroundCenter();
    } else if (shouldFaceLeft && isFacingRight) {
      isFacingRight = false;
      _headSprite.flipHorizontallyAroundCenter();
      _bodySprite.flipHorizontallyAroundCenter();
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

  void marioAnimationUpdate(double dt) {
    MarioAnimationState newState;

    if (!isOnGround) {
      newState = MarioAnimationState.jumping;
    } else if (_hAxisInput < 0 || _hAxisInput > 0) {
      newState = MarioAnimationState.walking;

      // Update walking animation timer
      _walkAnimationTimer += dt;
      if (_walkAnimationTimer >= _walkAnimationSpeed) {
        _walkAnimationTimer = 0;
        _showWalkFrame = !_showWalkFrame;
      }
    } else {
      newState = MarioAnimationState.idle;
      _walkAnimationTimer = 0;
      _showWalkFrame = false;
    }

    // Update body sprite if state changed or walking animation frame changed
    if (_currentState != newState ||
        (newState == MarioAnimationState.walking && _walkAnimationTimer == 0)) {
      _currentState = newState;
      updateBodySprite();
    }
  }

  void updateBodySprite() {
    switch (_currentState) {
      case MarioAnimationState.idle:
        _bodySprite.sprite = _bodyIdle;
        break;
      case MarioAnimationState.walking:
        // Alternate between idle and walk sprite
        _bodySprite.sprite = _showWalkFrame ? _bodyWalk : _bodyIdle;
        break;
      case MarioAnimationState.jumping:
        _bodySprite.sprite = _bodyJump;
        break;
    }
  }

  void updateSpritePositions() {
    // Head is on top half
    _headSprite.position = Vector2(0, -size.y / 4);
    // Body is on bottom half
    _bodySprite.position = Vector2(0, size.y / 4);
  }

  @override
  Future<void> onLoad() async {
    // Load body sprites
    _bodyIdle = await Sprite.load('mario_body_idle.png');
    _bodyWalk = await Sprite.load('mario_body_walk.png');
    _bodyJump = await Sprite.load('mario_body_jump.png');

    // Check if custom face exists
    final hasCustom = await FaceStorage.hasCustomFace();
    if (hasCustom) {
      final facePath = await FaceStorage.getFacePath();
      if (facePath != null && File(facePath).existsSync()) {
        _useCustomFace = true;
        final bytes = await File(facePath).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        _customFaceSprite = Sprite(frame.image);
      }
    }

    // Load default head sprite if no custom face
    if (!_useCustomFace) {
      final headSprite = await Sprite.load('mario_head.png');
      _customFaceSprite = headSprite;
    }

    // Create head componentx
    _headSprite = SpriteComponent(
      sprite: _customFaceSprite,
      size: Vector2(size.x * 1.2, size.y * 0.75),
      anchor: Anchor.center,
    );

    // Create body component
    _bodySprite = SpriteComponent(
      sprite: _bodyIdle,
      size: Vector2(size.x, size.y / 2),
      anchor: Anchor.center,
    );

    add(_headSprite);
    add(_bodySprite);

    updateSpritePositions();

    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Platform) {
      if (intersectionPoints.length == 2) {
        platformPositionCheck(intersectionPoints);
      }
    }
  }

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

  // Reload face (call this after user picks new face)
  // Reload face (call this after user picks new face)
  Future<void> reloadFace() async {
    final hasCustom = await FaceStorage.hasCustomFace();
    if (hasCustom) {
      final facePath = await FaceStorage.getFacePath();
      if (facePath != null && File(facePath).existsSync()) {
        final bytes = await File(facePath).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        _customFaceSprite = Sprite(frame.image);
        _headSprite.sprite = _customFaceSprite;
        _useCustomFace = true;
      }
    }
  }
}
