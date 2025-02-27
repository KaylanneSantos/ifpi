import 'package:flutter/material.dart';
import 'view/game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Basketball Game',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const GameScreen(),
    );
  }
}