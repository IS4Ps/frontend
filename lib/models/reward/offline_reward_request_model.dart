// 오프라인 보상 등록

class OfflineRewardRequestModel {
  final int childId;
  final String periodType; // "WEEKLY" 또는 "MONTHLY"
  final int targetPercent;
  final String rewardPromiseText;

  OfflineRewardRequestModel({
    required this.childId,
    required this.periodType,
    required this.targetPercent,
    required this.rewardPromiseText,
  });

  // 서버로 데이터를 보낼 때 JSON 형식으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      "childId": childId,
      "periodType": periodType,
      "targetPercent": targetPercent,
      "rewardPromiseText": rewardPromiseText,
    };
  }
}