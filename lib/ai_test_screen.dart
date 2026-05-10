import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiTestScreen extends StatefulWidget {
  @override
  _AiTestScreenState createState() => _AiTestScreenState();
}

class _AiTestScreenState extends State<AiTestScreen> {
  String _resultText = "버튼을 눌러 AI 추천을 받아보세요!";
  bool _isLoading = false;

  // ⭐️ [백엔드 API 연동 가이드]
  Future<void> fetchAiRecommendation() async {
    setState(() {
      _isLoading = true;
      _resultText = "AI가 열심히 생각 중입니다... 🤔";
    });

    try {
      // 1. 진짜 API 주소 (테스트를 위해 childId를 1로 하드코딩)
      // 실제 앱 연동 시에는 '1' 자리에 동적으로 변수(childId)를 넣으면됩니다 !
      final url = Uri.parse('http://100.27.204.252:8080/api/v1/missions/ai-recommend/1');

      // 2. HTTP POST 요청 (이번 API는 Body 데이터가 필요 없음!)
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      // 3. 응답 처리 로직
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          // 백엔드 ApiResponse 구조에 맞춰서 알맹이 빼오기
          // data 안에 List 형태로 미션들이 들어있으니, 몇 개 생성됐는지 보여줌
          var missionList = decodedData['data'] as List;
          _resultText = "✅ ${decodedData['message']}\n총 ${missionList.length}개의 미션이 생성됨!";
        });
      } else {
        setState(() {
          _resultText = "서버 에러 발생: 상태 코드 ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _resultText = "통신 실패 (서버 확인 필요): $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI 추천 API 테스트')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _resultText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: fetchAiRecommendation,
                      child: Text('✨ AI 루틴 생성하기 ✨'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}