import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
// import other screens as you create them

class AppRoutes {
  static const String home = '/';
  // static const String planner = '/planner';
  // static const String exams = '/exams';
  // static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => HomeScreen(),
        // planner: (context) => PlannerScreen(),
        // exams: (context) => ExamScreen(),
        // settings: (context) => SettingsScreen(),
      };
}
