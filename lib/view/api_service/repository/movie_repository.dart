import 'package:pick_flix/models/movie_detail_model.dart';
import 'package:pick_flix/models/search_result.dart';
import '../../../models/movie_model.dart';
import '../ApiService.dart';

class MovieRepository {
  final ApiService apiService;

  MovieRepository(this.apiService);

  /// ✅ دالة عامة لجلب الأفلام أو المسلسلات حسب النوع والفئة
  Future<List<Movie>> fetchContent({
    required String source, // "movie" or "tv"
    required String category, // e.g., "popular", "top_rated", "upcoming"
    int page = 1,
  }) {
    return apiService.fetchMovies("$source/$category", page: page);
  }



  /// ✅ جلب المحتوى الترند
  Future<List<Movie>> fetchTrending({
    required String source, // "movie" or "tv"
    int page = 1,
  }) {
    return apiService.fetchMovies("trending/$source/week", page: page);
  }

  /// ✅ جلب الأفلام المشابهة
  Future<List<Movie>> fetchSimilarMovies({
    required int id,
    required String source, // "movie" or "tv"
    int page = 1,
  }) {
    return apiService.fetchSimilar(id: id, source: source, page: page);
  }

  /// ✅ جلب المحتوى حسب النوع (Genres)
  Future<List<Movie>> fetchMoviesByGenres({
    required int genreId,
    int page = 1,
  }) {
    return apiService.fetchMoviesByGenres(genreId, page: page);
  }

  /// ✅ جلب المحتوى حسب التقييم
  Future<List<Movie>> getMoviesByRating({
    double minRating = 7,
    int page = 1,
  }) {
    return apiService.getMoviesByRating(minRating: minRating, page: page);
  }


  /// ✅ تفاصيل فيلم أو مسلسل
  Future<MovieDetail> getMovieDetails({
    required int id,
    required String source, // "movie" or "tv"
  }) {
    return apiService.getDetails(id: id, source: source);
  }

  /// ✅ بحث متعدد
  Future<List<SearchResult>> searchMovies(String query, {int page = 1}) {
    return apiService.searchMulti(query, page: page);
  }


  Future<void> toggleFavorite({
    required int accountId,
    required String sessionId,
    required int mediaId,
    required String mediaType,
    required bool favorite,
  }) {
    return apiService.markAsFavorite(
      accountId: accountId,
      sessionId: sessionId,
      mediaId: mediaId,
      mediaType: mediaType,
      favorite: favorite,
    );
  }

  Future<List<Movie>> fetchFavorites({
    required int accountId,
    required String sessionId,
    required String mediaType,
    int page = 1,
  }) {
    return apiService.getFavorites(
      accountId: accountId,
      sessionId: sessionId,
      mediaType: mediaType,
      page: page,
    );
  }

  Future<void> toggleWatchlist({
    required int accountId,
    required String sessionId,
    required int mediaId,
    required String mediaType,
    required bool watchlist,
  }) {
    return apiService.addToWatchlist(
      accountId: accountId,
      sessionId: sessionId,
      mediaId: mediaId,
      mediaType: mediaType,
      watchlist: watchlist,
    );
  }



  Future<List<Movie>> fetchWatchlist({
    required int accountId,
    required String sessionId,
    required String mediaType, // "movie" أو "tv"

    int page = 1,
  }) {
    return apiService.getWatchlist(
      mediaType: mediaType,
      accountId: accountId,
      sessionId: sessionId,
      page: page,
    );
  }


}
