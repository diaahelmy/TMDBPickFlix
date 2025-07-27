import '../../../models/movie_model.dart';
import '../ApiService.dart';


class MovieRepository {
  final ApiService apiService;

  MovieRepository(this.apiService);

  Future<List<Movie>> fetchTopRatedMovies() {
    return apiService.fetchMovies("movie/top_rated");
  }

  Future<List<Movie>> fetchTopRatedWatchAllTime() {
    return apiService.fetchMovies("tv/top_rated");

  }
  // ✅ Add separate method for popular movies
  Future<List<Movie>> fetchPopularMovies() {
    return apiService.fetchMovies("movie/popular"); // This will get popular movies
  }

}
