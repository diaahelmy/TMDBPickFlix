import 'package:pick_flix/models/movie_detail_model.dart';
import 'package:pick_flix/models/search_result.dart';

import '../../../models/movie_model.dart';
import '../ApiService.dart';


class MovieRepository {
  final ApiService apiService;

  MovieRepository(this.apiService);

  Future<List<Movie>> fetchTopRatedTv({int page = 1}) {
    return apiService.fetchMovies("tv/top_rated", page: page);
  }

  Future<List<Movie>> fetchTopRatedMovies({int page = 1}) {
    return apiService.fetchMovies("movie/top_rated", page: page);

  }
  Future<List<Movie>> fetchUpComingMovies({int page = 1}) {
    return apiService.fetchMovies("movie/upcoming", page: page);
  }

  // ✅ Add separate method for popular movies
  Future<List<Movie>> fetchPopularMovies({int page = 1}) {
    return apiService.fetchMovies("movie/popular", page: page);
  }
  Future<List<Movie>> fetchPopularTv({int page = 1}) {
    return apiService.fetchMovies("tv/popular", page: page);
  }
  Future<List<Movie>> fetchNowPlayingMovies({int page = 1}) {
    return apiService.fetchMovies("movie/now_playing", page: page);
  }
  Future<List<Movie>> fetchNowPlayingTv({int page = 1}) {
    return apiService.fetchMovies("tv/on_the_air", page: page);
  }
  Future<List<Movie>> fetchTrendingMovies({int page = 1}) {
    return apiService.fetchMovies("trending/movie/week", page: page);
  }
  Future<List<Movie>> fetchTrendingTv({int page = 1}) {
    return apiService.fetchMovies("trending/tv/week", page: page);
  }
  Future<List<Movie>> fetchSimilarMovies({
    required int id,
    required String source, // "movie" or "tv"
    int page = 1,
  }) {
    return apiService.fetchSimilar(
      id: id,
      source: source,
      page: page,
    );
  }
  Future<List<Movie>> fetchMoviesByGenres({ required int genreIds,int page = 1}) {
    return apiService.fetchMoviesByGenres(genreIds, page: page);
  }
  Future<List<Movie>> getMoviesByRating({double minRating = 7, int page = 1}) {
    return apiService.getMoviesByRating(minRating: minRating, page: page);
  }
  Future<MovieDetail> getMovieDetails({
    required int id,
    required String source,
  }) {
    return apiService.getDetails(id: id, source: source);
  }



  Future<List<SearchResult>> searchMovies(String query, {int page = 1}) {
    return apiService.searchMulti(query, page: page);
  }



}
