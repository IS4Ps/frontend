class MonthlyStatsModel {
  final int year;
  final int month;
  final String startDate;
  final String endDate;
  final int successDays;
  final int totalDays;
  final double monthlySuccessRate;
  final double avgCompletionRate;
  final List<DailyStatModel> dailyList;

  MonthlyStatsModel({
    required this.year,
    required this.month,
    required this.startDate,
    required this.endDate,
    required this.successDays,
    required this.totalDays,
    required this.monthlySuccessRate,
    required this.avgCompletionRate,
    required this.dailyList,
  });

  factory MonthlyStatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return MonthlyStatsModel(
      year: data['year'],
      month: data['month'],
      startDate: data['startDate'],
      endDate: data['endDate'],
      successDays: data['successDays'],
      totalDays: data['totalDays'],
      monthlySuccessRate: (data['monthlySuccessRate'] ?? 0).toDouble(),
      avgCompletionRate: (data['avgCompletionRate'] ?? 0).toDouble(),
      dailyList: (data['dailyList'] as List)
          .map((e) => DailyStatModel.fromJson(e))
          .toList(),
    );
  }
}

class DailyStatModel {
  final String date;
  final int totalCount;
  final int completedCount;
  final double completionRate;
  final bool isSuccess;

  DailyStatModel({
    required this.date,
    required this.totalCount,
    required this.completedCount,
    required this.completionRate,
    required this.isSuccess,
  });

  factory DailyStatModel.fromJson(Map<String, dynamic> json) {
    return DailyStatModel(
      date: json['date'],
      totalCount: json['totalCount'],
      completedCount: json['completedCount'],
      completionRate: (json['completionRate'] ?? 0).toDouble(),
      isSuccess: json['isSuccess'],
    );
  }
}