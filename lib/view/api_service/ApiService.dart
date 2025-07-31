  import 'dart:convert';

  import 'package:http/http.dart' as http;

  import '../../models/movie_model.dart';
  import '../../models/search_result.dart';
import '../../ui/component/search/widgets/search_result_grid.dart';

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
    Future<List<SearchResult>> searchMulti(String query, {int page = 1}) async {
      final url = '$_baseUrl/search/multi?api_key=$_apiKey&language=en-US&query=$query&page=$page';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List results = data['results'];

        return results.map((json) => SearchResult.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search multi');
      }
    }


    Future<List<Movie>> fetchSimilar({
      required int id,
      required String source, // "movie" or "tv"
      int page = 1,
    }) async {
      final url = '$_baseUrl/$source/$id/similar?api_key=$_apiKey&language=en-US&page=$page';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List movies = data['results'];
        return movies.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load similar $source');
      }
    }

    Future<List<Movie>> fetchMoviesByGenres(int genreId, {int page = 1}) async {
      final url = '$_baseUrl/discover/movie?api_key=$_apiKey&language=en-US&with_genres=$genreId&page=$page';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List movies = data['results'];
        return movies.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movies by genres');
      }
    }

    Future<Movie> getMovieDetails(int movieId) async {
      final url = '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=en-US';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Movie.fromJson(data);
      } else {
        throw Exception('Failed to load movie details');
      }
    }



    Future<List<Movie>> getMoviesByRating({double minRating = 7, int page = 1}) async {
      final response = await http.get(
        Uri.parse('$_baseUrl/discover/movie?api_key=$_apiKey&language=en-US&vote_average.gte=$minRating&page=$page&sort_by=vote_average.desc'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List movies = data['results'];
        return movies.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movies by rating');
      }
    }
  }
