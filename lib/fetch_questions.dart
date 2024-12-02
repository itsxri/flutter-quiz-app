import 'dart:convert';
import 'package:http/http.dart' as http;

/// Fetch trivia questions from the Open Trivia Database API.
///
/// Parameters:
/// - [questionCount]: Number of questions to fetch.
/// - [category]: The category ID for the trivia questions.
/// - [difficulty]: The difficulty level ("easy", "medium", "hard").
/// - [type]: The type of questions ("multiple" or "boolean").
///
/// Returns a list of trivia questions.
Future<List<dynamic>> fetchQuestions(
    int questionCount, String category, String difficulty, String type) async {
  final url = Uri.parse(
      'https://opentdb.com/api.php?amount=$questionCount&category=$category&difficulty=$difficulty&type=$type');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['response_code'] == 0) {
      return data['results'];
    } else {
      throw Exception('No questions available for the selected options.');
    }
  } else {
    throw Exception('Failed to fetch questions. Status code: ${response.statusCode}');
  }
}

/// Fetch trivia categories from the Open Trivia Database API.
///
/// Returns a list of categories with their names and IDs.
Future<List<dynamic>> fetchCategories() async {
  final url = Uri.parse('https://opentdb.com/api_category.php');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['trivia_categories'];
  } else {
    throw Exception('Failed to fetch categories. Status code: ${response.statusCode}');
  }
}
