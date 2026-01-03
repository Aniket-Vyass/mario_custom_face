import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:mario_game/constants/globals.dart';
import 'package:mario_game/constants/sprite_sheets.dart';

class AnimationConfigs {
  AnimationConfigs._(); //The underscore makes this a private constructor
  //This means you CAN'T do: AnimationConfigs() to create an instance
  //WHY would we do this? Because this class is just a container/organizer, not meant to be created as an object
  //It's like a filing cabinet - you don't need multiple filing cabinets, you just need ONE to hold your folders

  static GoombaAnimationConfigs goomba = GoombaAnimationConfigs();
  static MarioAnimationConfigs mario = MarioAnimationConfigs();
  static BlockConfigs block = BlockConfigs();
}

class BlockConfigs {
  SpriteAnimation mysteryBlockIdle() => SpriteAnimation.variableSpriteList(
    List<Sprite>.generate(
      3, // 👈 How many sprites to create
      (index) => SpriteSheets.itemBlocksSpriteSheet.getSprite(8, 5 + index),
      //(index) means What to do for each one (index goes like: 0, 1, 2)
      // So this gets sprites at (8,5), (8,6), (8,7)
      //Idle = 3 pictures looping fast → “bling bling bling” looping three images to make it look animated
      //
    ),
    stepTimes: List<double>.generate(
      3,
      (index) => Globals.mysteryBlockStepTime,
    ),
  );

  SpriteAnimation mysteryBlockHit() => SpriteAnimation.variableSpriteList(
    [
      SpriteSheets.itemBlocksSpriteSheet.getSprite(7, 8),
    ], //Hit = 1 picture → “box is now empty, no blinking”
    stepTimes: [Globals.mysteryBlockStepTime],
  );
  //👆WHY do this? Because the game engine expects a 👉"SpriteAnimation" type👈, not a single Sprite
  //It's like using a video format for a still image - technically works, just seems weird

  SpriteAnimation brickBlockIdle() => SpriteAnimation.variableSpriteList(
    [
      SpriteSheets.itemBlocksSpriteSheet.getSprite(7, 17),
    ], //show image on row 7 and column 17 of sprite sheet
    stepTimes: [Globals.mysteryBlockStepTime],
  );

  SpriteAnimation brickBlockHit() => SpriteAnimation.variableSpriteList(
    [
      SpriteSheets.itemBlocksSpriteSheet.getSprite(7, 19),
    ], //show image on row 7 and column 19 of sprite sheet
    stepTimes: [double.infinity],
  );
}

class GoombaAnimationConfigs {
  SpriteAnimation walking() => SpriteAnimation.variableSpriteList(
    List<Sprite>.generate(
      2,
      (index) => SpriteSheets.goombaSpriteSheet.getSprite(0, index),
    ),
    stepTimes: List<double>.generate(
      2,
      (index) => Globals.goombaSpriteStepTime,
    ),
  );

  SpriteAnimation dead() => SpriteAnimation.variableSpriteList(
    [SpriteSheets.goombaSpriteSheet.getSprite(0, 2)],
    stepTimes: [Globals.goombaSpriteStepTime],
  );
}

class MarioAnimationConfigs {
  Future<SpriteAnimation> idle() async => SpriteAnimation.spriteList([
    await Sprite.load(Globals.marioIdle),
  ], stepTime: Globals.marioSpriteStepTime);

  Future<SpriteAnimation> walking() async => SpriteAnimation.spriteList(
    await Future.wait(
      [1, 2, 3].map((i) => Sprite.load('mario_${i}_walk.gif')).toList(),
    ),
    stepTime: Globals.marioSpriteStepTime,
  );

  Future<SpriteAnimation> jumping() async => SpriteAnimation.spriteList([
    await Sprite.load(Globals.marioJump),
  ], stepTime: Globals.marioSpriteStepTime);
}
