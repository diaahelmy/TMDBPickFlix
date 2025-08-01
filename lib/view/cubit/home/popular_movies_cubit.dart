import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../api_service/repository/movie_repository.dart';
import 'home_popular_state.dart';

class HomePopularCubit extends Cubit<HomePopularState> {
  final MovieRepository repository;
  HomePopularCubit(this.repository) : super(HomePopularInitial());

  int _currentPage = 1;
  List<Movie> _popularMovies = [];
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;

  bool hasErrorLoadingMore = false;

  List<Movie> get cachedPopularMovies => _popularMovies;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasReachedMax => _hasReachedMax;

  Future<void> fetchPopularMovies({bool loadMore = false}) async {
    try {
      if (_isLoadingMore && loadMore) return;
      if (loadMore && _hasReachedMax) return;

      hasErrorLoadingMore = false;

      if (!loadMore) {
        emit(HomePopularLoading());
        _currentPage = 1;
        _popularMovies.clear();
        _hasReachedMax = false;
        _isLoadingMore = false;
      } else {
        _isLoadingMore = true;
        emit(HomePopularLoaded(List.of(_popularMovies)));
      }

      final newMovies = await repository.fetchPopularMovies(page: _currentPage);

      if (newMovies.length < 20) {
        _hasReachedMax = true;
      }

      if (newMovies.isNotEmpty) {
        _popularMovies.addAll(newMovies);
        _currentPage++;
      } else {
        _hasReachedMax = true;
      }

      emit(HomePopularLoaded(List.of(_popularMovies)));
    } catch (e) {
      debugPrint("❌ Error fetching popular movies: $e");


      if (loadMore) {
        hasErrorLoadingMore = true;
        emit(HomePopularLoaded(List.of(_popularMovies))); // don't show full-screen error
      } else {
        emit(HomePopularError(e.toString()));
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  // Method to refresh the data
  Future<void> refresh() async {
    await fetchPopularMovies(loadMore: false);
  }

  // Method to clear cache
  void clearCache() {
    _popularMovies.clear();
    _currentPage = 1;
    _hasReachedMax = false;
    _isLoadingMore = false;
    emit(HomePopularInitial());
  }
}