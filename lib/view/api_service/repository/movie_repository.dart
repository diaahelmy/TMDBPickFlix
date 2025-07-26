import '../../../models/movie_model.dart';
import '../ApiService.dart';


class MovieRepository {
  final ApiService _apiService = ApiService();

  Future<List<Movie>> fetchPopularMovies() async {
    return await _apiService.fetchPopularMovies();
  }

  Future<List<Movie>> fetchTopRatedMovies() async {
    return await _apiService.fetchTopRatedMovies();
  }
}
