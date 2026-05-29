// 미니게임 결과 저장

class MinigameLogRequestModel {
  final int childId;
  final String gameType;
  final int score;
  final int rewardAmount;

  MinigameLogRequestModel({
    required this.childId,
    required this.gameType,
    required this.score,
    required this.rewardAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'gameType': gameType,
      'score': score,
      'rewardAmount': rewardAmount,
    };
  }
}