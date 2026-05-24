import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screens/quest/routine_detail_screen.dart';
import '../../view_model/quest/quest_view_model.dart';
import '../../models/quest/today_mission_model.dart';

class RoutineScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onGrowTap;
  const RoutineScreen({super.key, this.onBack, this.onGrowTap});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  Map<int, bool> _expandedMap = {};
  Map<int, int> _selectedSubTaskIndexMap = {};
  Map<int, List<bool>> _doneLists = {};
  bool _isStarting = false;

  // 미션별 타이머 관리
  Map<int, Timer?> _missionTimers = {};
  Map<int, int> _remainingSecondsMap = {};
  Map<int, int> _totalSecondsMap = {};

  List<bool> getDoneList(int missionId, int taskCount, String status) {
    if (status == "COMPLETED") {
      return List.filled(taskCount, true);
    }
    if (!_doneLists.containsKey(missionId) || _doneLists[missionId]!.length != taskCount) {
      _doneLists[missionId] = List.filled(taskCount, false);
    }
    return _doneLists[missionId]!;
  }

  Future<void> _saveDoneList(int missionId, List<bool> doneList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doneList_$missionId', jsonEncode(doneList));
  }

  void _startMissionTimer(int missionId, String startTime, String endTime) {
    // 이미 타이머가 실행 중이면 재시작하지 않음
    if (_missionTimers[missionId]?.isActive ?? false) {
      return;
    }

    final start = startTime.split(':');
    final end = endTime.split(':');
    final startMinutes = int.parse(start[0]) * 60 + int.parse(start[1]);
    final endMinutes = int.parse(end[0]) * 60 + int.parse(end[1]);
    final totalSeconds = (endMinutes - startMinutes) * 60;

    _totalSecondsMap[missionId] = totalSeconds;
    _remainingSecondsMap[missionId] = totalSeconds;

    _missionTimers[missionId]?.cancel();
    _missionTimers[missionId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSecondsMap[missionId]! <= 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingSecondsMap[missionId] = _remainingSecondsMap[missionId]! - 1;
        });
      }
    });
  }

  int _getRemainingSeconds(int missionId) {
    return _remainingSecondsMap[missionId] ?? 0;
  }

  int _getTotalSeconds(int missionId) {
    return _totalSecondsMap[missionId] ?? 1;
  }

  Future<List<bool>> _loadDoneList(int missionId, int taskCount) async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('doneList_$missionId');
    if (saved != null) {
      final List<dynamic> decoded = jsonDecode(saved);
      return decoded.map((e) => e as bool).toList();
    }
    return List.filled(taskCount, false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final viewModel = context.read<QuestViewModel>();
        await viewModel.fetchTodayMissions();
        await viewModel.fetchWeeklyStats();

        for (final mission in viewModel.todayMissions) {
          final saved = await _loadDoneList(mission.missionId, mission.smallTasks.length);
          setState(() {
            _doneLists[mission.missionId] = saved;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _missionTimers.values.forEach((timer) => timer?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F6F6),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6389E9)))
              : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 10),
                _buildAchievementCard(viewModel),
                const SizedBox(height: 19),
                _buildActionButton("캐릭터 성장하기!!", const Color(0xFFE9807B), widget.onGrowTap),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("오늘의 퀘스트!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      if (viewModel.todayMissions.isEmpty)
                        _buildEmptyQuestCard()
                      else
                        ...viewModel.todayMissions.asMap().entries.map((entry) {
                          int idx = entry.key;
                          TodayMissionModel mission = entry.value;

                          if (idx == 0) {
                            return _buildMainQuestCard(mission);
                          } else {
                            TodayMissionModel prevMission = viewModel.todayMissions[idx - 1];
                            if (prevMission.status == "COMPLETED") {
                              return Padding(
                                padding: const EdgeInsets.only(top: 9),
                                child: _buildMainQuestCard(mission),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 9),
                              child: _buildLockedQuestCard(mission.bigTaskTitle),
                            );
                          }
                        }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 24),
        onPressed: () {
          if (widget.onBack != null) {
            widget.onBack!();
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildEmptyQuestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "오늘 예정된 퀘스트가 없습니다.",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(QuestViewModel viewModel) {
    final stats = viewModel.weeklyStats;

    double progressValue = stats != null ? stats.weeklySuccessRate / 100 : 0.0;
    String statusText = stats != null
        ? "${stats.successDays}/${stats.totalDays}일 성공 (${stats.weeklySuccessRate.toInt()}%)"
        : "데이터를 불러오는 중...";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("주간 퀘스트 달성률", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              if (stats?.isRewardEligible ?? false)
                _buildStatusLabel("보상 획득!", const Color(0xFFFFEBEB), const Color(0xFFE9807B)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 18,
              backgroundColor: const Color(0xFFE2E2E2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6389E9)),
            ),
          ),
          const SizedBox(height: 8),
          Text(statusText, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          child: Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildMainQuestCard(TodayMissionModel mission) {
    final doneList = getDoneList(mission.missionId, mission.smallTasks.length, mission.status);
    final tasks = mission.smallTasks.map((e) => {"title": e.title}).toList();
    final selectedIndex = _selectedSubTaskIndexMap[mission.missionId] ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.bigTaskTitle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (_missionTimers[mission.missionId]?.isActive ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "남은 시간: ${(_getRemainingSeconds(mission.missionId) ~/ 60).toString().padLeft(2, '0')}:${(_getRemainingSeconds(mission.missionId) % 60).toString().padLeft(2, '0')}",
                          style: TextStyle(
                            fontSize: 14,
                            color: _getRemainingSeconds(mission.missionId) < 300
                                ? Colors.red
                                : const Color(0xFF6389E9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (_isStarting) return;
                  setState(() => _isStarting = true);

                  final viewModel = context.read<QuestViewModel>();

                  if (doneList.isNotEmpty && doneList.every((done) => done)) {
                    _missionTimers[mission.missionId]?.cancel();
                    await viewModel.completeMission(mission.missionId);
                    await viewModel.fetchTodayMissions();
                    setState(() => _isStarting = false);
                    return;
                  }

                  if (mission.status == "PENDING") {
                    await viewModel.startMission(mission.missionId);
                    _startMissionTimer(mission.missionId, mission.startTime, mission.endTime);
                  }

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutineDetailScreen(
                        taskTitle: tasks[selectedIndex]['title']!,
                        mainQuestTitle: mission.bigTaskTitle,
                        startTime: mission.startTime,
                        endTime: mission.endTime,
                        remainingSeconds: _getRemainingSeconds(mission.missionId),
                        totalSeconds: _getTotalSeconds(mission.missionId),
                        onTimerUpdate: (remaining) {
                          if (mounted) {
                            setState(() {
                              _remainingSecondsMap[mission.missionId] = remaining;
                            });
                          }
                        },
                      ),
                    ),
                  );

                  if (result == true) {
                    setState(() {
                      _doneLists[mission.missionId]![selectedIndex] = true;
                      if (selectedIndex < tasks.length - 1) {
                        _selectedSubTaskIndexMap[mission.missionId] = selectedIndex + 1;
                      }
                    });
                    _saveDoneList(mission.missionId, _doneLists[mission.missionId]!);
                  }
                  setState(() => _isStarting = false);
                },
                child: _buildStatusLabel(
                  doneList.isNotEmpty && doneList.every((done) => done)
                      ? "퀘스트 완료하기"
                      : mission.status == "PENDING" ? "퀘스트 시작하기"
                      : mission.status == "COMPLETED" ? "완료됨"
                      : "계속하기",
                  mission.status == "COMPLETED"
                      ? const Color(0xFFE3E3E3)
                      : const Color(0xFF6389E9),
                  mission.status == "COMPLETED"
                      ? Colors.grey
                      : Colors.white,
                ),
              ),
            ],
          ),
          if (_expandedMap[mission.missionId] ?? true) ...[
            const SizedBox(height: 20),
            Column(
              children: tasks.asMap().entries.map((entry) {
                return _buildSubTask(
                  entry.key,
                  entry.value['title']!,
                  doneList[entry.key],
                  mission.missionId,
                  selectedIndex,
                );
              }).toList(),
            ),
          ],
          IconButton(
            onPressed: () => setState(() {
              _expandedMap[mission.missionId] = !(_expandedMap[mission.missionId] ?? true);
            }),
            icon: Icon((_expandedMap[mission.missionId] ?? true) ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTask(int index, String title, bool isDone, int missionId, int selectedIndex) {
    return GestureDetector(
      onTap: isDone ? null : () => setState(() {
        _selectedSubTaskIndexMap[missionId] = index;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFC6FF8C) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(35),
          border: (!isDone && selectedIndex == index) ? Border.all(color: const Color(0xFF6389E9), width: 1) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Icon(isDone ? Icons.check_circle : Icons.circle_outlined, size: 22, color: isDone ? Colors.black : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedQuestCard(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _buildStatusLabel("이전 퀘스트 진행 중", const Color(0xFFE3E3E3), Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }
}