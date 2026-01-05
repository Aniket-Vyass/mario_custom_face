import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mario_game/games/super_mario_bros_game.dart';
import 'package:mario_game/utils/face_storage.dart';
import 'package:path_provider/path_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SuperMarioBrosGame game;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    game = SuperMarioBrosGame();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        // Save to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'custom_mario_face.png';
        final savedImage = await File(
          image.path,
        ).copy('${appDir.path}/$fileName');

        // Save path
        await FaceStorage.saveFacePath(savedImage.path);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Face uploaded! Restart game to see changes.'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Restart game to apply new face
        setState(() {
          game = SuperMarioBrosGame();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetToDefault() async {
    await FaceStorage.clearFace();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset to default Mario! Restart game to see changes.'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Restart game
    setState(() {
      game = SuperMarioBrosGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game
          GameWidget(game: game),

          // Face picker button (top right)
          Positioned(
            top: 40,
            right: 10,
            child: Column(
              children: [
                // Upload face button
                Material(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                  elevation: 4,
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.face,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Reset button
                Material(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(30),
                  elevation: 4,
                  child: InkWell(
                    onTap: _resetToDefault,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
