import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mario_game/screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 👈 ADD THIS

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mario_custom_face', //Me as Mario
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameScreen(),
    );
  }
}
