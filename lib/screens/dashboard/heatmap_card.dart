import 'package:flutter/material.dart';

class HeatmapCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<int> data;

  const HeatmapCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFF1F3F5),
      const Color(0xFFBDECC7),
      const Color(0xFF2ED573),
      const Color(0xFF138A36),
    ];

    final now = DateTime.now();
    final months = [
      DateTime(now.year, now.month - 2, 1),
      DateTime(now.year, now.month - 1, 1),
      DateTime(now.year, now.month, 1),
    ];

    // 3월 1일 요일 (일요일=0, 월요일=1, ..., 토요일=6)
    final startDate = months[0];
    final startWeekday = startDate.weekday % 7; // dart: 월=1,일=7 → 일=0

    // 앞에 빈칸 + 실제 데이터
    final totalData = List<int?>.filled(startWeekday, null) + data.map((e) => e as int?).toList();
    final colCount = (totalData.length / 7).ceil();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF3D3D3D))),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(colCount, (col) {
                return Expanded(
                  child: Column(
                    children: List.generate(7, (row) {
                      final index = col * 7 + row;
                      if (index >= totalData.length) {
                        return const SizedBox(height: 14);
                      }
                      final value = totalData[index];
                      if (value == null) {
                        return const SizedBox(height: 17); // 빈칸 (앞 여백)
                      }
                      return Container(
                        margin: const EdgeInsets.all(1.5),
                        height: 14,
                        decoration: BoxDecoration(
                          color: colors[value],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('${months[0].month}월', style: const TextStyle(fontSize: 12, color: Color(0xFF3D3D3D))),
                const SizedBox(width: 76),
                Text('${months[1].month}월', style: const TextStyle(fontSize: 12, color: Color(0xFF3D3D3D))),
                const SizedBox(width: 60),
                Text('${months[2].month}월', style: const TextStyle(fontSize: 12, color: Color(0xFF3D3D3D))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}