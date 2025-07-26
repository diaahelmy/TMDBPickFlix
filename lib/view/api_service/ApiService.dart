import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/movie_model.dart';

class ApiService {
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String _apiKey = 'e730ecc0b4579e83d7cef9408afc75b1';

  Future<List<Movie>> fetchMovies(String endpoint, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint?api_key=$_apiKey&language=en-US&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List movies = data['results'];
      return movies.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load $endpoint movies');
    }
  }
}
