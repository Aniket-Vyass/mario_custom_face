import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class FaceStorage {
  static const String _facePathKey = 'custom_face_path';

  // Save custom face path
  static Future<void> saveFacePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_facePathKey, path);
  }

  // Get custom face path
  static Future<String?> getFacePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_facePathKey);
  }

  // Check if custom face exists
  static Future<bool> hasCustomFace() async {
    final path = await getFacePath();
    if (path == null) return false;
    return File(path).existsSync();
  }

  // Clear custom face
  static Future<void> clearFace() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_facePathKey);
  }
}
