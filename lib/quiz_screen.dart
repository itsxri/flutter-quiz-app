import 'package:flutter/material.dart';
import 'dart:async';
import 'fetch_questions.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> settings;

  QuizScreen({required this.settings});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<dynamic>> _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = 15; // Timer starts at 15 seconds
  Timer? _timer;
  List<List<String>> _shuffledAnswers = [];
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    _questions = fetchQuestions(
      widget.settings['questionCount'],
      widget.settings['category'],
      widget.settings['difficulty'],
      widget.settings['type'],
    );
    _questions.then((questions) {
      _precomputeShuffledAnswers(questions);
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _precomputeShuffledAnswers(List<dynamic> questions) {
    for (var question in questions) {
      final answers = List<String>.from(question['incorrect_answers'])
        ..add(question['correct_answer'])
        ..shuffle();
      _shuffledAnswers.add(answers);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        _showFeedback('Time\'s up!', correctAnswer: true);
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 15; // Reset timer
    });
    _startTimer();
  }

  void _moveToNextQuestion() {
    setState(() {
      _feedbackMessage = null; // Clear feedback
    });

    if (_currentQuestionIndex + 1 < widget.settings['questionCount']) {
      setState(() {
        _currentQuestionIndex++;
      });
      _resetTimer();
    } else {
      _showFinalScoreDialog();
    }
  }

  void _showFeedback(String feedback, {bool correctAnswer = false, String? answer}) {
    setState(() {
      _feedbackMessage = feedback;
    });

    Future.delayed(Duration(seconds: 2), () {
      if (correctAnswer && answer == null) {
        _moveToNextQuestion();
      } else {
        _moveToNextQuestion();
      }
    });
  }

  void _showFinalScoreDialog() {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quiz Completed!'),
          content: Text('Your final score is $_score.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the setup screen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: _questions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final questions = snapshot.data!;
            final question = questions[_currentQuestionIndex];
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
                        value: _timeLeft / 15, // Timer progress
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[400]!),
                        backgroundColor: Colors.pink[50],
                      ),
                      Text(
                        '$_timeLeft',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink[800]),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Score: $_score',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink[800]),
                  ),
                  SizedBox(height: 20),
                  Text(
                    question['question'], // Display the question
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  if (_feedbackMessage != null)
                    Text(
                      _feedbackMessage!,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink[800]),
                    ),
                  if (_feedbackMessage == null) ...answers.map((answer) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[400],
                      ),
                      onPressed: () {
                        final isCorrect = answer == question['correct_answer'];
                        if (isCorrect) {
                          setState(() {
                            _score++;
                          });
                          _showFeedback('Correct!', correctAnswer: true);
                        } else {
                          _showFeedback('Incorrect! Correct answer: ${question['correct_answer']}');
                        }
                      },
                      child: Text(answer),
                    );
                  }).toList(),
                ],
              ),
            );
          } else {
            return Center(child: Text('No questions available.'));
          }
        },
      ),
    );
  }
}
