import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("오늘의 기분은 어때?"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context), // 이전 화면(QuestScreen)으로 돌아가기
        ),
      ),
      body: const Center(
        child: Text("여기에 기분 선택 UI를 만드세요!", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}