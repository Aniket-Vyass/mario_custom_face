import 'package:mario_game/constants/globals.dart';

enum LevelOption {
  lv_1_1(Globals.lv_1_1, '1-1');

  const LevelOption(this.path, this.name);

  final String path;
  final String name;
}
