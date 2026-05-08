import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routine_date_selector.dart';
import '../../view_model/routine/preset_view_model.dart';

Future<void> showRoutineLoadModal(BuildContext context) {
  int selectedIndex = 0;
  int selectedDay = DateTime.now().day;
  bool isFullCalendarOpen = false;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final viewModel = Provider.of<PresetViewModel>(context, listen: false);
    viewModel.getPresets();
  });

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF1586E2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '반복루틴 불러오기',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'JejuGothic',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  WeekCalendarWidget(
                    selectedDay: selectedDay,
                    isFullCalendarOpen: isFullCalendarOpen,
                    onDaySelected: (day) {
                      setState(() {
                        selectedDay = day;
                      });
                    },
                    onToggleCalendar: () {
                      setState(() {
                        isFullCalendarOpen = !isFullCalendarOpen;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  Consumer<PresetViewModel>(
                    builder: (context, viewModel, _) {
                      if (viewModel.isLoading) {
                        return const CircularProgressIndicator();
                      }
                      return Column(
                        children: List.generate(viewModel.presets.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => selectedIndex = index),
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFCCCCCC)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.save_outlined, size: 20, color: Color(0xFF555555)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        viewModel.presets[index]['title'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontFamily: 'JejuGothic',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        final TextEditingController editController =
                                        TextEditingController(text: viewModel.presets[index]['title']);
                                        await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('프리셋 수정'),
                                            content: TextField(controller: editController),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('취소'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  await viewModel.updatePreset(
                                                    presetId: viewModel.presets[index]['presetId'],
                                                    title: editController.text,
                                                  );
                                                },
                                                child: const Text('저장'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: const Icon(Icons.edit, size: 18, color: Color(0xFF555555)),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        await viewModel.deletePreset(viewModel.presets[index]['presetId']);
                                      },
                                      child: const Icon(Icons.delete, size: 18, color: Color(0xFFE05555)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 110,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'JejuGothic',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 110,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1586E2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '불러오기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'JejuGothic',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}