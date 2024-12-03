import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchQuestions(
    int questionCount, String category, String difficulty, String type) async {
  try {
    final url = Uri.parse(
        'https://opentdb.com/api.php?amount=$questionCount&category=$category&difficulty=$difficulty&type=$type');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['response_code'] == 0) {
        return data['results'] as List<dynamic>;
      } else {
        throw Exception('No questions available for the selected settings.');
      }
    } else {
      throw Exception('Failed to load questions. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching questions: $e');
  }
}

Future<List<Map<String, String>>> fetchCategories() async {
  try {
    final url = Uri.parse('https://opentdb.com/api_category.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['trivia_categories'] as List<dynamic>)
          .map((category) => {
                'id': category['id'].toString(),
                'name': category['name'].toString(),
              })
          .toList();
    } else {
      throw Exception('Failed to load categories. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching categories: $e');
  }
}
