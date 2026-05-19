// 오늘의 미션 목록 조회

class SmallTaskModel {
  final int smallTaskId;
  final String title;
  final int orderIndex;

  SmallTaskModel({
    required this.smallTaskId,
    required this.title,
    required this.orderIndex,
  });

  factory SmallTaskModel.fromJson(Map<String, dynamic> json) {
    return SmallTaskModel(
      smallTaskId: json['smallTaskId'] ?? 0,
      title: json['title'] ?? '',
      orderIndex: json['orderIndex'] ?? 0,
    );
  }
}

class TodayMissionModel {
  final int missionId;
  final String presetTitle;
  final String bigTaskTitle;
  final int assignedExp;
  final String date;
  final String startTime;
  final String endTime;
  final String status;
  final String? startedAt;
  final String? completedAt;
  final String? approvedAt;
  final List<SmallTaskModel> smallTasks;

  TodayMissionModel({
    required this.missionId,
    required this.presetTitle,
    required this.bigTaskTitle,
    required this.assignedExp,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.approvedAt,
    required this.smallTasks,
  });

  factory TodayMissionModel.fromJson(Map<String, dynamic> json) {
    return TodayMissionModel(
      missionId: json['missionId'] ?? 0,
      presetTitle: json['presetTitle'] ?? '',
      bigTaskTitle: json['bigTaskTitle'] ?? '',
      assignedExp: json['assignedExp'] ?? 0,
      date: json['date'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      status: json['status'] ?? 'PENDING',
      startedAt: json['startedAt'],
      completedAt: json['completedAt'],
      approvedAt: json['approvedAt'],
      smallTasks: (json['smallTasks'] as List? ?? [])
          .map((e) => SmallTaskModel.fromJson(e))
          .toList(),
    );
  }
}