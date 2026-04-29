import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'view_model/quest/quest_view_model.dart';
import 'start_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 웹뷰 플랫폼 초기화 로직 추가
  if (WebViewPlatform.instance == null) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }

  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestViewModel()),
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1687E3)),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}