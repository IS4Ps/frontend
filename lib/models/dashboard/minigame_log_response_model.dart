// 미니게임 기록 조회

class MinigameLogResponseModel {
  final int logId;
  final String gameType;
  final int score;
  final int rewardAmount;

  MinigameLogResponseModel({
    required this.logId,
    required this.gameType,
    required this.score,
    required this.rewardAmount,
  });

  factory MinigameLogResponseModel.fromJson(Map<String, dynamic> json) {
    return MinigameLogResponseModel(
      logId: json['logId'] ?? 0,
      gameType: json['gameType'] ?? '',
      score: json['score'] ?? 0,
      rewardAmount: json['rewardAmount'] ?? 0,
    );
  }
}