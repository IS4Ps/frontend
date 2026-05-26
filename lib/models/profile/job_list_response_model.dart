// 직업 목록 조회


class JobListResponseModel {
  // 명세서 최상단에 "data"라는 이름의 리스트(배열)가 바로 들어옵니다.
  final List<JobModel> data;

  JobListResponseModel({required this.data});

  factory JobListResponseModel.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>?;

    return JobListResponseModel(
      data: dataList != null
          ? dataList.map((item) => JobModel.fromJson(item as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

class JobModel {
  final int id;
  final String jobCode;
  final String jobName;
  final String description;
  final int baseStrength;
  final int baseIntelligence;
  final int baseCreativity;

  JobModel({
    required this.id,
    required this.jobCode,
    required this.jobName,
    required this.description,
    required this.baseStrength,
    required this.baseIntelligence,
    required this.baseCreativity,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as int,
      jobCode: json['jobCode'] as String? ?? '',
      jobName: json['jobName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      baseStrength: json['baseStrength'] as int? ?? 0,
      baseIntelligence: json['baseIntelligence'] as int? ?? 0,
      baseCreativity: json['baseCreativity'] as int? ?? 0,
    );
  }
}