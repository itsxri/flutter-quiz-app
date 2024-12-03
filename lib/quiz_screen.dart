import 'package:flutter/material.dart';
import 'dart:async';
import 'fetch_questions.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> settings;

  const QuizScreen({required this.settings, Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<void> _fetchQuestionsFuture;
  late List<dynamic> _questions;
  late List<List<String>> _shuffledAnswers;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = 15;
  Timer? _timer;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  void _initializeQuiz() {
    _questions = [];
    _shuffledAnswers = [];
    _currentQuestionIndex = 0;
    _score = 0;
    _feedbackMessage = null;
    _timeLeft = 15;

    _fetchQuestionsFuture = fetchQuestions(
      widget.settings['questionCount'],
      widget.settings['category'],
      widget.settings['difficulty'],
      widget.settings['type'],
    ).then((questions) {
      setState(() {
        _questions = questions.map((q) {
          // Add an `answeredCorrectly` field for tracking
          q['answeredCorrectly'] = null;
          return q;
        }).toList();
        _shuffledAnswers = _questions.map((q) {
          final answers = List<String>.from(q['incorrect_answers'])
            ..add(q['correct_answer'])
            ..shuffle();
          return answers;
        }).toList();
      });
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        _handleTimeOut();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 15;
    });
    _startTimer();
  }

  void _moveToNextQuestion() {
    setState(() {
      _feedbackMessage = null;
    });

    if (_currentQuestionIndex + 1 < _questions.length) {
      setState(() {
        _currentQuestionIndex++;
      });
      _resetTimer();
    } else {
      _showFinalScoreDialog();
    }
  }

  void _handleTimeOut() {
    setState(() {
      _feedbackMessage = "Time's up!";
      _questions[_currentQuestionIndex]['answeredCorrectly'] = false;
    });
    Future.delayed(const Duration(seconds: 2), _moveToNextQuestion);
  }

  void _showFinalScoreDialog() {
    final missedQuestions = _questions
        .where((question) => question['answeredCorrectly'] == false)
        .map((question) => {
              'question': question['question'].toString(),
              'correctAnswer': question['correct_answer'].toString(),
            })
        .toList();

    Navigator.pushReplacementNamed(
      context,
      '/summary',
      arguments: {
        'totalQuestions': _questions.length,
        'correctAnswers': _score,
        'missedQuestions': missedQuestions,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _fetchQuestionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (_questions.isEmpty) {
            return const Center(child: Text('No questions found.'));
          } else {
            final question = _questions[_currentQuestionIndex];
            final answers = _shuffledAnswers[_currentQuestionIndex];

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.pink[100]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _timeLeft / 15,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                        backgroundColor: Colors.pink[50],
                      ),
                      Text(
                        '$_timeLeft',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Score: $_score',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    question['question'],
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (_feedbackMessage != null)
                    Text(
                      _feedbackMessage!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _feedbackMessage == "Correct!" ? Colors.green : Colors.red,
                      ),
                    ),
                  const SizedBox(height: 20),
                  ...answers.map((answer) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[400],
                      ),
                      onPressed: () {
                        final isCorrect = answer == question['correct_answer'];
                        setState(() {
                          _feedbackMessage = isCorrect ? "Correct!" : "Incorrect!";
                          _questions[_currentQuestionIndex]['answeredCorrectly'] = isCorrect;
                          if (isCorrect) {
                            _score++;
                          }
                        });
                        Future.delayed(const Duration(seconds: 2), _moveToNextQuestion);
                      },
                      child: Text(answer),
                    );
                  }).toList(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
