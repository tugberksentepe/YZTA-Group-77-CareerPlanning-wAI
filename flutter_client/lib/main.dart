import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/api_service.dart';
import 'services/questionnaire_provider.dart';
import 'services/career_plan_provider.dart';
import 'screens/home_screen.dart';
import 'screens/questionnaire_screen.dart';
import 'screens/career_plan_screen.dart';

Future<void> main() async {

  await dotenv.load(fileName: '.env');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final apiService = ApiService();
    
    return MultiProvider(
      providers: [

        ChangeNotifierProvider(
          create: (_) => QuestionnaireProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => CareerPlanProvider(apiService: apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Kariyer Planlama',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2A3990),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A3990),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/questionnaire': (context) => const QuestionnaireScreen(),
          '/career-plan': (context) => const CareerPlanScreen(),
        },
      ),
    );
  }
} 