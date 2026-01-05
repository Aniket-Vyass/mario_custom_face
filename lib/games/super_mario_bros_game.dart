// ignore_for_file: unused_import, unused_local_variable
import 'package:flame/collisions.dart';
import 'package:mario_game/actors/mario.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flame/components.dart'; //This has the World component&Camera already no need to import separately
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:mario_game/constants/globals.dart';
import 'package:mario_game/constants/sprite_sheets.dart';
import 'package:mario_game/level/level_component.dart';
import 'package:mario_game/level/level_option.dart';

class SuperMarioBrosGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late CameraComponent cameraComponent;
  Mario? player; // 🔑 NOT late

  final World world =
      World(); //World is the component that holds all game objects eg. everything in the game
  // Load your game assets and initialize game components here
  LevelComponent? _currentLevel;

  @override
  Future<void> onLoad() async {
    await SpriteSheets.load();

    // ✅ CREATE CAMERA FIRST
    cameraComponent = CameraComponent(world: world)
      ..viewfinder.anchor = Anchor.center
      ..viewfinder.zoom = 2.0;

    addAll([world, cameraComponent]);

    // ✅ THEN load level (LevelComponent uses camera)
    loadlevel(LevelOption.lv_1_1);

    await super.onLoad();
  }

  void loadlevel(LevelOption option) {
    _currentLevel?.removeFromParent();
    _currentLevel = LevelComponent(option);
    world.add(_currentLevel!);
  }

  @override
  Color backgroundColor() => const Color(0xFF5C94FC);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (!isLoaded) return; // 🔑 IMPORTANT

    cameraComponent.viewfinder.zoom = size.x / 800;
  }
}
