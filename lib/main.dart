import 'package:flutter/material.dart';
import 'setup_screen.dart';
import 'quiz_screen.dart';

void main() => runApp(QuizApp());

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      initialRoute: '/',
      routes: {
        '/': (context) => SetupScreen(),
        '/quiz': (context) => QuizScreen(settings: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
      },
    );
  }
}
