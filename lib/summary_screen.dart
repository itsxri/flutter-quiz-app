import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final totalQuestions = args['totalQuestions'] as int;
    final correctAnswers = args['correctAnswers'] as int;
    final missedQuestions = args['missedQuestions'] as List<Map<String, String>>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Summary'),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.red[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Score: $correctAnswers / $totalQuestions',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (missedQuestions.isNotEmpty) ...[
                const Text(
                  'Missed Questions:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView(
                    children: missedQuestions
                        .map((q) => ListTile(
                              title: Text(q['question']!),
                              subtitle: Text('Correct Answer: ${q['correctAnswer']}'),
                            ))
                        .toList(),
                  ),
                ),
              ] else
                const Text(
                  'Perfect Score!',
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                child: const Text('Return to Setup'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Try Again feature not implemented yet!')),
                  );
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
