// 아이 프로필 생성 (request)

class ChildProfileRequestModel {
  final String nickname;
  final String lastConnectedDeviceId;

  ChildProfileRequestModel({
    required this.nickname,
    required this.lastConnectedDeviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'lastConnectedDeviceId': lastConnectedDeviceId,
    };
  }
}