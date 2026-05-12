import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../common/dio_client.dart';

class QuizApiService {
  Future<List<Map<String, dynamic>>> generateQuiz(
      List<XFile> images, int childId) async {
    final List<Map<String, String>> imageList = [];
    for (final image in images) {
      final bytes = await File(image.path).readAsBytes();
      final base64Str = base64Encode(bytes);
      imageList.add({'imageBase64': base64Str});
    }

    final response = await DioClient.dio.post(
      '/api/v1/ai-quizzes/generate',
      data: {
        'childId': childId,
        'category': '일반',
        'images': imageList,
      },
    );

    print('[API 호출] AI 퀴즈 생성');
    print('[응답 데이터] ${response.data}');

    final data = response.data;
    return List<Map<String, dynamic>>.from(data['data']['quizzes']);
  }
}