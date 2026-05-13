class ChildInformationResponseModel {
  final int? childId;
  final String? nickname;
  final int? level;
  final int? currentExp;
  final int? gold;
  final int? statStrength;
  final int? statIntelligence;
  final int? statCreativity;

  ChildInformationResponseModel({
    this.childId,
    this.nickname,
    this.level,
    this.currentExp,
    this.gold,
    this.statStrength,
    this.statIntelligence,
    this.statCreativity,
  });

  factory ChildInformationResponseModel.fromJson(Map<String, dynamic> json) {
    // 🚀 명세서 이미지 보면 "data" 안에 내용이 들어있죠?
    final data = json['data'] as Map<String, dynamic>?;

    return ChildInformationResponseModel(
      childId: data?['childId'],
      nickname: data?['nickname'],
      level: data?['level'],
      currentExp: data?['currentExp'],
      gold: data?['gold'],
      statStrength: data?['statStrength'],
      statIntelligence: data?['statIntelligence'],
      statCreativity: data?['statCreativity'],
    );
  }
}