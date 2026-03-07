import 'package:flutter/material.dart';
import 'main_screen.dart'; // 우리가 만든 파일을 불러와야 해!

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IS4Ps',
      debugShowCheckedModeBanner: false, // 오른쪽 위 디버그 띠 제거
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1687E3)),
        useMaterial3: true,
      ),
      // 앱이 켜지면 보여줄 첫 화면 설정
      home: const MainScreen(),
    );
  }
}