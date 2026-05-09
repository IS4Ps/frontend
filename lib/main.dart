import 'package:flutter/material.dart';
import 'package:frontend/view_model/routine/big_task_view_model.dart';
import 'package:frontend/view_model/routine/preset_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
// 카카오 SDK 임포트 추가
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'view_model/dashboard/dashboard_view_model.dart';
import 'view_model/quest/quest_view_model.dart';
import 'view_model/reward/reward_view_model.dart';
import 'start_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 카카오 SDK 초기화 (본인의 네이티브 앱 키 입력)
  // 이미지(image_f1e30d.png)에서 확인한 키를 여기에 넣습니다.
  KakaoSdk.init(nativeAppKey: 'b83532b20b25865de4745d49050ecc79');

  // 2. [중요] 내 컴퓨터의 키 해시를 디버그 콘솔에 출력합니다.
  // 이 코드를 통해 나온 값을 카카오 개발자 센터에 등록해야 로그인이 작동합니다.
  print("내 키 해시: ${await KakaoSdk.origin}");

  if (WebViewPlatform.instance == null) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }

  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => RewardViewModel()),
        ChangeNotifierProvider(create: (_) => BigTaskViewModel()),
        ChangeNotifierProvider(create: (_) => PresetViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

// MyApp 클래스 부분은 기존과 동일하므로 생략합니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IS4Ps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1687E3)),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}