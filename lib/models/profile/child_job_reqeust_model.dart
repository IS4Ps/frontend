// 직업 선택 api


class ChildJobRequestModel {
  final int jobId;

  ChildJobRequestModel({
    required this.jobId,
  });

  // 모델 객체를 서버 전송용 Map(Json) 구조로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      "jobId": jobId,
    };
  }
}