import 'package:flutter/material.dart';

class SpeechBubble extends StatefulWidget {
  const SpeechBubble({super.key});

  @override
  State<SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends State<SpeechBubble> {
  int? selectedIndex;
  int? selectedDetailIndex;
  bool isDetailView = false;

  // 1단계: 메인 기분 데이터
  final List<Map<String, dynamic>> moods = [
    {'emoji': '😆', 'label': '매우 좋음', 'sub': '신나요', 'color': const Color(0xFFFFE169)},
    {'emoji': '😊', 'label': '좋음', 'sub': '뿌듯해요', 'color': const Color(0xFFAFDAA6)},
    {'emoji': '😐', 'label': '보통', 'sub': '그저 그래요', 'color': const Color(0xFFC9E6F5)},
    {'emoji': '😟', 'label': '나쁨', 'sub': '속상해요', 'color': const Color(0xFFFFCBA4)},
    {'emoji': '😭', 'label': '매우 나쁨', 'sub': '화나요', 'color': const Color(0xFFFFB0B0)},
  ];

  // 2단계: 상세 감정 데이터 (각자 다른 배경색 & 글자색 설정)
  final List<Map<String, dynamic>> detailMoods = [
    {'label': '행복해요', 'color': const Color(0xFFC6FF8C), 'textColor': const Color(0xFF4E7A1E)},
    {'label': '편안해요', 'color': const Color(0xFFE1EFFF), 'textColor': const Color(0xFF4A608A)},
    {'label': '감사해요', 'color': const Color(0xFFE9807B), 'textColor': const Color(0xFF8B2F2B)},
    {'label': '활기차요', 'color': const Color(0xFFE8B7FF), 'textColor': const Color(0xFF7B3DA0)},
    {'label': '화사해요', 'color': const Color(0xFFF9E2E2), 'textColor': const Color(0xFF9E4B4B)},
    {'label': '쾌적해요', 'color': const Color(0xFFF1FFAD), 'textColor': const Color(0xFF6F7A1E)},
  ];

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = isDetailView
        ? selectedDetailIndex != null
        : selectedIndex != null;

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF7297E3), width: 2.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isDetailView ? "구체적으로 어떤 기분인가요?" : "오늘의 기분은 어때?",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A90E2)),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 140,
            child: isDetailView ? _buildDetailView() : _buildMainView(),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: isButtonEnabled
                ? () {
              if (!isDetailView) {
                setState(() => isDetailView = true);
              } else {
                Navigator.pop(context);
              }
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonEnabled ? const Color(0xFF5C85E5) : const Color(0xFFD1D1D1),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              elevation: 0,
            ),
            child: Text(
              "선택 완료",
              style: TextStyle(
                  color: isButtonEnabled ? Colors.white : Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(moods.length, (index) {
        bool isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () => setState(() => selectedIndex = index),
          child: Opacity(
            opacity: selectedIndex == null || isSelected ? 1.0 : 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: moods[index]['color'],
                  child: Text(moods[index]['emoji'], style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 6),
                Text(moods[index]['label'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: moods[index]['color'],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    moods[index]['sub'],
                    style: const TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetailView() {
    return Center(
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: List.generate(detailMoods.length, (index) {
          bool isSelected = selectedDetailIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedDetailIndex = index),
            child: Container(
              width: 85,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: detailMoods[index]['color'],
                borderRadius: BorderRadius.circular(50),
                // 선택 시에만 테두리를 강조해서 보여줍니다.
                border: isSelected ? Border.all(color: const Color(0xFF5C85E5), width: 2) : null,
              ),
              child: Center(
                child: Text(
                  detailMoods[index]['label'],
                  style: TextStyle(
                    // 여기서 각 데이터에 설정된 textColor를 적용합니다!
                    color: detailMoods[index]['textColor'],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}