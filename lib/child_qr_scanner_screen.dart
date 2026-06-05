import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart'; // Provider 추가
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../view_model/profile/profile_view_model.dart'; // ViewModel 경로 확인
import '../child_main_screen.dart';
import 'auth/token_manager.dart';

class ChildQrScannerScreen extends StatefulWidget {
  const ChildQrScannerScreen({super.key});

  @override
  State<ChildQrScannerScreen> createState() => _ChildQrScannerScreenState();
}

class _ChildQrScannerScreenState extends State<ChildQrScannerScreen> {
  bool isScanned = false; // 중복 스캔 방지

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('부모님 기기 QR 스캔'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          const Center(
            child: Text(
              '에뮬레이터에서는 QR 스캔 불가',
              style: TextStyle(color: Colors.white),
            ),
          ),
          // 가이드 라인 디자인
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1687E3), width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: const Text(
              '부모님 앱의 QR 코드를 사각형 안에 맞춰주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ 새로운 연동 로직: linkToken을 사용하여 서버에 최종 연동 요청
  // ChildQrScannerScreen.dart 내부 _handleQrSuccess 함수 수정

  Future<void> _handleQrSuccess(String combinedData) async {
    final profileVM = context.read<ProfileViewModel>();
    
    // ✅ [FCM 토큰 추출] 가짜 ID 대신 진짜 토큰을 가져옵니다.
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    
    // 토큰을 못 가져올 경우를 대비한 기본값
    final String deviceId = fcmToken ?? "unknown_child_device_${DateTime.now().millisecondsSinceEpoch}";
    debugPrint('🚀 발급된 아이 FCM 토큰: $deviceId');

    try {
      // ✅ 쉼표로 데이터 분리 (linkToken, parentToken)
      final List<String> parts = combinedData.split(',');
      final String linkToken = parts[0];

      if (parts.length >= 2) {
        final String parentToken = parts[1];

        // ✅ 403 에러 방지를 위해 부모 토큰을 미리 SharedPreferences에 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('parentTokenBackup', parentToken);
        await TokenManager().setParentToken(parentToken);
        debugPrint('✅ 부모 토큰 백업 완료');
      }

      // 1. 서버에 linkToken으로 최종 연동 요청
      bool success = await profileVM.linkDeviceAndLogin(linkToken, deviceId);

      if (success && mounted) {
        _showSuccessDialog();
      } else {
        throw Exception("연동 실패");
      }
    } catch (e) {
      debugPrint('연동 처리 에러: $e');
      if (mounted) {
        setState(() => isScanned = false); // 다시 스캔 가능하게 변경
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('연동에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('연동 성공!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('부모님 기기와 성공적으로 연결되었습니다.\n이제 모험을 시작해볼까요?'),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const ChildMainScreen()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1687E3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('시작하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}