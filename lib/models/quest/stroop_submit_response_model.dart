// stroop 정답 제출 (response)

class StroopSubmitResponseModel {
  final int correctCount;
  final int wrongCount;
  final int totalCount;
  final double accuracy;
  final double avgResponseTime;
  final int score;
  final int rewardGold;
  final int statCreativityGain;

  StroopSubmitResponseModel({
    required this.correctCount,
    required this.wrongCount,
    required this.totalCount,
    required this.accuracy,
    required this.avgResponseTime,
    required this.score,
    required this.rewardGold,
    required this.statCreativityGain,
  });

  factory StroopSubmitResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> targetJson = (json.containsKey('data') && json['data'] != null)
        ? json['data'] as Map<String, dynamic>
        : json;

    return StroopSubmitResponseModel(
      // null 값이 혹시 섞여 들어오더라도 앱이 터지지 않게 디폴트 값을 안전하게 매핑
      correctCount: targetJson['correctCount'] ?? 0,
      wrongCount: targetJson['wrongCount'] ?? 0,
      totalCount: targetJson['totalCount'] ?? 20,
      accuracy: (targetJson['accuracy'] as num?)?.toDouble() ?? 0.0,
      avgResponseTime: (targetJson['avgResponseTime'] as num?)?.toDouble() ?? 0.0,
      score: targetJson['score'] ?? 0,
      rewardGold: targetJson['rewardGold'] ?? 0,
      statCreativityGain: targetJson['statCreativityGain'] ?? 0,
    );
  }
}