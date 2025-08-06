import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/movie_model.dart';
import '../../../api_service/repository/movie_repository.dart';
import '../../tab_change/TabState.dart';
import 'home_upcoming_state.dart';

class HomeUpcomingCubit extends Cubit<HomeUpcomingState> {
  final MovieRepository repository;
  HomeUpcomingCubit(this.repository) : super(HomeUpcomingInitial());

  int _currentPage = 1;
  final List<Movie> _upcomingMovies = [];
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;

  bool hasErrorLoadingMore = false;

  List<Movie> get cachedUpcomingMovies => _upcomingMovies;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasReachedMax => _hasReachedMax;

  Future<void> fetchUpcomingMovies(ContentType type, {bool loadMore = false}) async {
    try {
      if (_isLoadingMore && loadMore) return;
      if (loadMore && _hasReachedMax) return;

      hasErrorLoadingMore = false;

      if (!loadMore) {
        emit(HomeUpcomingLoading());
        _currentPage = 1;
        _upcomingMovies.clear();
        _hasReachedMax = false;
        _isLoadingMore = false;
      } else {
        _isLoadingMore = true;
        emit(HomeUpcomingLoaded(List.of(_upcomingMovies)));
      }

      final source = type == ContentType.movie ? "movie" : "tv";

      // ✅ الفارق هنا: لو TV Shows نستخدم on_the_air بدل upcoming
      final category = type == ContentType.movie ? "upcoming" : "on_the_air";

      final newMovies = await repository.fetchContent(
        source: source,
        category: category,
        page: _currentPage,
      );

      if (newMovies.length < 20) {
        _hasReachedMax = true;
      }

      if (newMovies.isNotEmpty) {
        _upcomingMovies.addAll(newMovies);
        _currentPage++;
      } else {
        _hasReachedMax = true;
      }

      emit(HomeUpcomingLoaded(List.of(_upcomingMovies)));
    } catch (e) {
      debugPrint("❌ Error fetching upcoming movies: $e");

      if (loadMore) {
        hasErrorLoadingMore = true;
        emit(HomeUpcomingLoaded(List.of(_upcomingMovies)));
      } else {
        emit(HomeUpcomingError(e.toString()));
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh(ContentType type) async {
    await fetchUpcomingMovies(type, loadMore: false);
  }

  void clearCache() {
    _upcomingMovies.clear();
    _currentPage = 1;
    _hasReachedMax = false;
    _isLoadingMore = false;
    emit(HomeUpcomingInitial());
  }
}
