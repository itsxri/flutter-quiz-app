import 'package:flutter/material.dart';
import 'fetch_questions.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  List<dynamic> _categories = [];
  String? _selectedCategory;
  int _questionCount = 5;
  String _difficulty = 'easy';
  String _type = 'multiple';

  @override
  void initState() {
    super.initState();
    fetchCategories().then((categories) {
      setState(() {
        _categories = categories;
        _selectedCategory = _categories[0]['id'].toString(); // Default to the first category
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.pink[50],
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Customize Your Quiz',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[800],
                ),
              ),
              SizedBox(height: 20),
              DropdownButton<int>(
                value: _questionCount,
                items: [5, 10, 15]
                    .map((count) => DropdownMenuItem(value: count, child: Text('$count Questions')))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _questionCount = value!;
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category['id'].toString(),
                          child: Text(category['name']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: _difficulty,
                items: ['easy', 'medium', 'hard']
                    .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _difficulty = value!;
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: _type,
                items: [
                  DropdownMenuItem(value: 'multiple', child: Text('Multiple Choice')),
                  DropdownMenuItem(value: 'boolean', child: Text('True/False')),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/quiz', arguments: {
                    'questionCount': _questionCount,
                    'category': _selectedCategory,
                    'difficulty': _difficulty,
                    'type': _type,
                  });
                },
                child: Text('Start Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
