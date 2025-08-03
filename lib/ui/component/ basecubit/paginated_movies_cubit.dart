import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:pick_flix/ui/component/%20basecubit/paginated_movies_state.dart';

import '../../../models/movie_model.dart';


typedef FetchMoviesCallback = Future<List<Movie>> Function(int page);

class PaginatedMoviesCubit extends Cubit<PaginatedMoviesState> {
  final FetchMoviesCallback fetchMoviesCallback;

  PaginatedMoviesCubit(this.fetchMoviesCallback) : super(PaginatedMoviesInitial());

  int _currentPage = 1;
  final List<Movie> _movies = [];
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;

  bool hasErrorLoadingMore = false;

  List<Movie> get cachedMovies => _movies;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> fetchMovies({bool loadMore = false}) async {
    try {
      if (_isLoadingMore && loadMore) return;
      if (loadMore && _hasReachedMax) return;

      hasErrorLoadingMore = false;

      if (!loadMore) {
        emit(PaginatedMoviesLoading());
        _currentPage = 1;
        _movies.clear();
        _hasReachedMax = false;
        _isLoadingMore = false;
      } else {
        _isLoadingMore = true;
        emit(PaginatedMoviesLoaded(List.of(_movies)));
      }

      final newMovies = await fetchMoviesCallback(_currentPage);

      if (newMovies.length < 20) {
        _hasReachedMax = true;
      }

      if (newMovies.isNotEmpty) {
        _movies.addAll(newMovies);
        _currentPage++;
      } else {
        _hasReachedMax = true;
      }

      emit(PaginatedMoviesLoaded(List.of(_movies)));
    } catch (e) {
      debugPrint("❌ Error fetching movies: $e");

      if (loadMore) {
        hasErrorLoadingMore = true;
        emit(PaginatedMoviesLoaded(List.of(_movies))); // don't show full-screen error
      } else {
        emit(PaginatedMoviesError(e.toString()));
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    await fetchMovies(loadMore: false);
  }

  void clearCache() {
    _movies.clear();
    _currentPage = 1;
    _hasReachedMax = false;
    _isLoadingMore = false;
    emit(PaginatedMoviesInitial());
  }
}
