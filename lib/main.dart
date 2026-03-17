import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todolist/app_routes.dart';
import 'package:todolist/data/model/todo.dart';
import 'package:todolist/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 날짜 포맷 초기화 (한국어)
  await initializeDateFormatting('ko_KR');
  
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>('todos');
  await Hive.openBox('settings'); // 목표 저장을 위한 박스
  await Hive.openBox('achieved_goals'); // 달성 기록 저장을 위한 박스 추가

  setup();

  runApp(const TodoListApp());
}

class TodoListApp extends StatelessWidget {
  const TodoListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      // 한국어 로케일 설정
      locale: Locale('ko', 'KR'),
      supportedLocales: <Locale>[
        Locale('ko', 'KR'),
      ],
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
