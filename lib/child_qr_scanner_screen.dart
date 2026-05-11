import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/child_main_screen.dart';
import 'auth/token_manager.dart';
import 'child_main_screen.dart';

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
          // 1. QR 스캐너 카메라 뷰
          MobileScanner(
            onDetect: (capture) {
              if (isScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() => isScanned = true);

                  final String childId = barcode.rawValue!;
                  debugPrint('스캔된 자녀 ID: $childId');

                  // 스캔 성공 후 저장 및 화면 전환 로직 실행
                  _handleQrSuccess(childId);
                  break;
                }
              }
            },
          ),

          // 2. 스캔 가이드 라인 (디자인 요소)
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

          // 3. 하단 설명 텍스트
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

  // 데이터 저장 및 화면 이동 처리
  // ChildQrScannerScreen.dart 내부 _handleQrSuccess 함수 수정

  Future<void> _handleQrSuccess(String rawData) async {
    try {
      // 1. QR 데이터 분리 ("ID,DeviceId,ParentToken")
      final List<String> parts = rawData.split(',');
      final String childId = parts[0];
      final String deviceId = parts.length > 1 ? parts[1] : "device-001";
      final String? parentToken = parts.length > 2 ? parts[2] : null;

      // 2. 기기에 정보 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isChildMode', true);
      await prefs.setString('selectedChildId', childId);
      await prefs.setString('lastConnectedDeviceId', deviceId);

      // 3. ✅ 핵심: 부모 토큰이 있다면 즉시 세팅 및 백업
      if (parentToken != null && parentToken.isNotEmpty) {
        TokenManager().setToken(parentToken);
        await prefs.setString('parentTokenBackup', parentToken);
        debugPrint('부모 토큰 연동 성공 및 백업 완료');
      }

      if (!mounted) return;

      // 성공 알림 팝업
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text(
                  '연동 성공!', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text('자녀 ID $childId번 계정과 연결되었습니다.'),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChildMainScreen()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1687E3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('시작하기', style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
      );
    } catch (e) {
      debugPrint('스캔 처리 에러: $e');
      if (mounted) {
        setState(() => isScanned = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR 코드 형식이 올바르지 않습니다.')),
        );
      }
    }
  }
}