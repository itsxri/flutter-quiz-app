import 'package:flutter/material.dart';
import 'fetch_questions.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _questionCount = 5;
  String? _category;
  String _difficulty = 'easy';
  String _type = 'multiple';
  late Future<List<Map<String, String>>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Quiz'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFE4E1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Customize Your Quiz',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              DropdownButton<int>(
                value: _questionCount,
                onChanged: (value) {
                  setState(() {
                    _questionCount = value!;
                  });
                },
                items: [5, 10, 15]
                    .map((count) => DropdownMenuItem<int>(
                          value: count,
                          child: Text('$count Questions'),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, String>>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Failed to load categories');
                  } else {
                    final categories = snapshot.data!;
                    return DropdownButton<String>(
                      value: _category ?? categories.first['id'],
                      onChanged: (value) {
                        setState(() {
                          _category = value;
                        });
                      },
                      items: categories
                          .map((category) => DropdownMenuItem<String>(
                                value: category['id'],
                                child: Text(category['name']!),
                              ))
                          .toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: _difficulty,
                onChanged: (value) {
                  setState(() {
                    _difficulty = value!;
                  });
                },
                items: ['easy', 'medium', 'hard']
                    .map((difficulty) => DropdownMenuItem<String>(
                          value: difficulty,
                          child: Text(difficulty[0].toUpperCase() + difficulty.substring(1)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: _type,
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
                items: [
                  DropdownMenuItem(value: 'multiple', child: Text('Multiple Choice')),
                  DropdownMenuItem(value: 'boolean', child: Text('True/False')),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/quiz',
                    arguments: {
                      'questionCount': _questionCount,
                      'category': _category ?? '9',
                      'difficulty': _difficulty,
                      'type': _type,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Start Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
