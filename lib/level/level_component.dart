import 'dart:math';
import 'package:flame/experimental.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:mario_game/actors/goomba.dart';
import 'package:mario_game/actors/mario.dart';
import 'package:mario_game/constants/globals.dart';
import 'package:mario_game/games/super_mario_bros_game.dart';
import 'package:mario_game/level/level_option.dart';
import 'package:mario_game/objects/blocks/brick_block.dart';
import 'package:mario_game/objects/blocks/mystery_block.dart';
import 'package:mario_game/objects/platform.dart';

class LevelComponent extends Component with HasGameRef<SuperMarioBrosGame> {
  final LevelOption option;

  late Rectangle _levelBounds;

  late Mario _mario;

  LevelComponent(this.option);

  @override
  Future<void> onLoad() async {
    final level = await TiledComponent.load(
      Globals.lv_1_1,
      Vector2.all(Globals.tileSize),
    );

    gameRef.world.add(level);

    _levelBounds = Rectangle.fromPoints(
      Vector2.zero(),
      Vector2(
            level.tileMap.map.width.toDouble(),
            level.tileMap.map.height.toDouble(),
          ) *
          Globals.tileSize,
    );

    createBlocks(level.tileMap);
    createActors(level.tileMap);
    createPlatforms(level.tileMap);

    _setupCamera();

    await super.onLoad();
  }

  void createBlocks(RenderableTiledMap tileMap) {
    // Create Actors
    ObjectGroup? blocksLayer = tileMap.getLayer<ObjectGroup>('Blocks');

    if (blocksLayer == null) {
      throw Exception('Blocks layer could not be found.');
    }
    for (final TiledObject obj in blocksLayer.objects) {
      switch (obj.name) {
        case 'Mystery': //assigning mystery object
          MysteryBlock mysteryBlock = MysteryBlock(
            position: Vector2(obj.x, obj.y),
          );

          gameRef.world.add(mysteryBlock);

          break;

        case 'Brick': //assigning mario object to the instance(mario.dart)
          print('🍄 Creating Brick at: ${obj.x}, ${obj.y}');
          BrickBlock brickBlock = BrickBlock(
            position: Vector2(obj.x, obj.y),
            shouldCrumble: Random().nextBool(),
          );

          gameRef.world.add(brickBlock);
          print('🍄 Goomba Brick to world');

          break;
        default:
          break;
      }
    }
  }

  // Create Actors
  void createActors(RenderableTiledMap tileMap) {
    // Create Actors
    ObjectGroup? actorsLayer = tileMap.getLayer<ObjectGroup>('Actors');
    if (actorsLayer == null) {
      throw Exception('Actors layer could not be found.');
    }
    for (final TiledObject obj in actorsLayer.objects) {
      switch (obj.name) {
        case 'Mario': //assigning mario object to the instance(mario.dart)
          _mario = Mario(
            position: Vector2(obj.x, obj.y),
            levelBounds: _levelBounds,
          );

          gameRef.world.add(_mario);

          break;

        case 'Goomba': //assigning Goomba object to the instance(goomba.dart)
          print('🍄 Creating Goomba at: ${obj.x}, ${obj.y}');
          Goomba goomba = Goomba(position: Vector2(obj.x, obj.y + obj.height));

          gameRef.world.add(goomba);
          print('🍄 Goomba added to world');

          break;
        default:
          break;
      }
      ;
    }
  }

  // Create Platforms.
  void createPlatforms(RenderableTiledMap tileMap) {
    // Create platforms.
    ObjectGroup? platformsLayer = tileMap.getLayer<ObjectGroup>('Platforms');
    if (platformsLayer == null) {
      throw Exception('Platforms layer not found.');
    }

    for (final TiledObject obj in platformsLayer.objects) {
      final Platform platform = Platform(
        position: Vector2(obj.x, obj.y),
        size: Vector2(obj.width, obj.height),
      );
      gameRef.world.add(platform);
    }
  }

  void _setupCamera() {
    final cameraOffset = Vector2(
      (gameRef.size.x / 2) / gameRef.cameraComponent.viewfinder.zoom,
      (gameRef.size.y / 2) / gameRef.cameraComponent.viewfinder.zoom,
    );

    // Add half of Mario's size to center on him
    final marioCenter = _mario.position + (_mario.size / 2);

    gameRef.cameraComponent.viewfinder.position = marioCenter - cameraOffset;

    gameRef.cameraComponent.follow(_mario, maxSpeed: 1000);

    gameRef.cameraComponent.setBounds(
      Rectangle.fromPoints(_levelBounds.topRight, _levelBounds.topLeft),
    );
  }
}
