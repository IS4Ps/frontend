// 아이 프로필 생성 (response)

class ChildProfileResponseModel {
  final bool success;
  final int code;
  final String message;
  final int? childId;

  ChildProfileResponseModel({
    required this.success,
    required this.code,
    required this.message,
    this.childId,
  });

  factory ChildProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ChildProfileResponseModel(
      success: json['success'],
      code: json['code'],
      message: json['message'],
      childId: json['data'] != null ? json['data']['childId'] : null,
    );
  }
}