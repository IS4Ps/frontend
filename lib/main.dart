import 'package:flutter/material.dart';
import 'start_screen.dart'; // 처음엔 시작 화면을 띄우기

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IS4Ps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1687E3)),
        useMaterial3: true,
      ),
      home: const StartScreen(), // 첫 화면은 시작 화면!
    );
  }
}