import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:mario_game/constants/globals.dart';

class SpriteSheets {
  static late SpriteSheet itemBlocksSpriteSheet;
  static late SpriteSheet goombaSpriteSheet;

  static Future<void> load() async {
    // Item Blocks Sprite Sheet
    final itemBlocksSpriteSheetImage = await Flame.images.load(
      Globals
          .blocksSpriteSheet, //This just stores the path to the block sprite sheet image in another file for clean code
    );
    itemBlocksSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: itemBlocksSpriteSheetImage,
      columns: 28,
      rows: 16,
    );

    // Goomba Sprite Sheet
    final goombaSpriteSheetImage = await Flame.images.load(
      Globals
          .goombaSpriteSheet, //This just stores the path to the goomba sprite sheet image in another file for clean code
    );
    goombaSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: goombaSpriteSheetImage,
      columns: 3,
      rows: 1,
    );
  }
}
