import 'package:flutter/material.dart';
import 'setup_screen.dart';
import 'quiz_screen.dart';
import 'summary_screen.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      initialRoute: '/',
      routes: {
        '/': (context) => const SetupScreen(),
        '/quiz': (context) {
          final settings = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return QuizScreen(settings: settings);
        },
        '/summary': (context) => const SummaryScreen(),
      },
    );
  }
}
