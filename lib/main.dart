import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/view_model/profile/profile_view_model.dart';
import 'package:frontend/view_model/routine/big_task_view_model.dart';
import 'package:frontend/view_model/routine/mission_view_model.dart';
import 'package:frontend/view_model/routine/preset_view_model.dart';
import 'package:frontend/view_model/setting/setting_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'view_model/dashboard/dashboard_view_model.dart';
import 'view_model/quest/quest_view_model.dart';
import 'view_model/reward/reward_view_model.dart';
import 'start_screen.dart';
import 'auth/token_manager.dart' as my_auth;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // 알림 권한 요청 (FCM 필수)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // ✅ 1. TokenManager 초기화 (로컬에 저장된 토큰/ID 복구)
  // 이 코드가 있어야 앱 재실행 시에도 데이터가 유지됩니다.
  await my_auth.TokenManager().init();

  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: 'b83532b20b25865de4745d49050ecc79',
    javaScriptAppKey: '여기에_JavaScript_키_입력',
  );

  // Android에서는 키 해시, iOS에서는 origin 확인용으로 출력됨
  print("카카오 origin: ${await KakaoSdk.origin}");

  // Android에서만 Android WebView 설정
  if (defaultTargetPlatform == TargetPlatform.android &&
      WebViewPlatform.instance == null) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }

  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {}

  // 1. 포그라운드 알림 수신 (앱 켜져 있을 때)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('포그라운드 알림: ${message.notification?.title}');
  });

  // 2. 백그라운드에서 알림 탭했을 때
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('백그라운드 알림 탭: ${message.notification?.title}');
  });

  // 3. 앱 완전 종료 상태에서 알림 탭했을 때
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // 페이지 이동 처리
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => RewardViewModel()),
        ChangeNotifierProvider(create: (_) => BigTaskViewModel()),
        ChangeNotifierProvider(create: (_) => PresetViewModel()),
        ChangeNotifierProvider(create: (_) => SettingViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => MissionViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IS4Ps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1687E3),
        ),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}