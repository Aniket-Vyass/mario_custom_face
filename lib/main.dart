import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:mario_game/constants/globals.dart';
import 'package:mario_game/constants/sprite_sheets.dart';
import 'package:mario_game/games/super_mario_bros_game.dart';

//to create an instance for the game
final SuperMarioBrosGame _superMarioBrosGame = SuperMarioBrosGame();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load sprite sheets.
  await SpriteSheets.load();

  await FlameAudio.audioCache.loadAll([
    Globals.jumpSmallSFX,
    Globals.pauseSFX,
    Globals.bumpSFX,
    Globals.powerUpAppearsSFX,
    Globals.breakBlockSFX,
  ]);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameWidget(game: _superMarioBrosGame),
    ),
  );
}
