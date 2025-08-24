import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../models/movie_detail_model.dart';
import '../../models/movie_model.dart';
import '../../models/search_result.dart';

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

    Future<String> createSession(String token) async {
      final url = '$_baseUrl/authentication/session/new?api_key=$_apiKey';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'request_token': token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['session_id'];
      } else {
        throw Exception('Failed to create session');
      }
    }

    Future<String> createRequestToken() async {
      final url = '$_baseUrl/authentication/token/new?api_key=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['request_token'];
      } else {
        throw Exception('Failed to create request token');
      }
    }

    Future<MovieDetail> getDetails({
      required int id,
      required String source, // "movie" or "tv"
    }) async {
      final url =
          '$_baseUrl/$source/$id?api_key=$_apiKey&language=en-US&append_to_response=videos,reviews';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MovieDetail.fromJson(data);
      } else {
        throw Exception('Failed to load $source details');
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


    /// ⬅️ Step 2: Validate Request Token with Login
    Future<String> validateWithLogin({
      required String username,
      required String password,
      required String requestToken,
    }) async {
      final url = '$_baseUrl/authentication/token/validate_with_login?api_key=$_apiKey';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'request_token': requestToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['request_token'];
      } else {
        throw Exception('Failed to validate token with login');
      }
    }

    // id in detils acouunt
    Future<Map<String, dynamic>> getAccountDetails(String sessionId) async {
      final url = '$_baseUrl/account?api_key=$_apiKey&session_id=$sessionId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200 && response.statusCode != 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch account details');
      }
      }

    Future<void> addToWatchlist({
        required int accountId,
        required String sessionId,
        required int mediaId,
        required String mediaType, // "movie" or "tv"
        required bool watchlist,
      }) async {
        final url = '$_baseUrl/account/$accountId/watchlist?api_key=$_apiKey&session_id=$sessionId';

        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "media_type": mediaType,
            "media_id": mediaId,
            "watchlist": watchlist,
          }),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Failed to update watchlist');
        }
      }
    String mapMediaTypeToEndpoint(String mediaType) {
      if (mediaType == MediaType.movie.name) return "movies";
      if (mediaType == MediaType.tv.name) return "tv";
      return mediaType;
    }

    Future<void> markAsFavorite({
      required int accountId,
      required String sessionId,
      required int mediaId,
      required String mediaType,
      required bool favorite,
    }) async {
      final url =
          '$_baseUrl/account/$accountId/favorite?api_key=$_apiKey&session_id=$sessionId';

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "media_type": mediaType,
          "media_id": mediaId,
          "favorite": favorite,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Failed to update favorite: ${response.statusCode} ${response.body}');
      } else {
        final data = jsonDecode(response.body);
        debugPrint("✅ Favorite updated successfully: $data");
      }
    }

    Future<List<Movie>> getFavorites({
      required int accountId,
      required String sessionId,
      required String mediaType,
      int page = 1,
    }) async {
      final endpoint = mapMediaTypeToEndpoint(mediaType);
      final url =
          '$_baseUrl/account/$accountId/favorite/$endpoint?api_key=$_apiKey&session_id=$sessionId&page=$page';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List items = data['results'];
        return items.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load favorite $mediaType');
      }
    }
    Future<List<Movie>> getWatchlist({
      required int accountId,
      required String sessionId,
      required String mediaType, // "movie" أو "tv"
      int page = 1,
    }) async {
      final endpoint = mapMediaTypeToEndpoint(mediaType);
      final url =
          '$_baseUrl/account/$accountId/watchlist/$endpoint?api_key=$_apiKey&session_id=$sessionId&page=$page';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200  ) {
        final data = jsonDecode(response.body);
        List items = data['results'];
        return items.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load watchlist $mediaType');
      }
    }


  }
