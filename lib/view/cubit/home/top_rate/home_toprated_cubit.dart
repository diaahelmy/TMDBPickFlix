import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/movie_model.dart';
import '../../../api_service/repository/movie_repository.dart';
import '../../tab_change/TabState.dart';
import 'home_toprated_state.dart';

class HomeTopRatedCubit extends Cubit<HomeTopRatedState> {
  final MovieRepository repository;
  HomeTopRatedCubit(this.repository) : super(HomeTopRatedInitial());

  int _currentPage = 1;
  final List<Movie> _topRatedMovies = [];
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;

  bool hasErrorLoadingMore = false;

  List<Movie> get cachedTopRatedMovies => _topRatedMovies;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasReachedMax => _hasReachedMax;

  Future<void> fetchTopRatedMovies(ContentType type, {bool loadMore = false}) async {
    try {
      if (_isLoadingMore && loadMore) return;
      if (loadMore && _hasReachedMax) return;

      hasErrorLoadingMore = false;

      if (!loadMore) {
        emit(HomeTopRatedLoading());
        _currentPage = 1;
        _topRatedMovies.clear();
        _hasReachedMax = false;
        _isLoadingMore = false;
      } else {
        _isLoadingMore = true;
        emit(HomeTopRatedLoaded(List.of(_topRatedMovies)));
      }

      final source = type == ContentType.movie ? "movie" : "tv";

      final newMovies = await repository.fetchContent(
        source: source,
        category: "top_rated",
        page: _currentPage,
      );

      if (newMovies.length < 20) {
        _hasReachedMax = true;
      }

      if (newMovies.isNotEmpty) {
        _topRatedMovies.addAll(newMovies);
        _currentPage++;
      } else {
        _hasReachedMax = true;
      }

      emit(HomeTopRatedLoaded(List.of(_topRatedMovies)));
    } catch (e) {
      debugPrint("❌ Error fetching top-rated movies: $e");

      if (loadMore) {
        hasErrorLoadingMore = true;
        emit(HomeTopRatedLoaded(List.of(_topRatedMovies)));
      } else {
        emit(HomeTopRatedError(e.toString()));
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh(ContentType type) async {
    await fetchTopRatedMovies(type, loadMore: false);
  }

  void clearCache() {
    _topRatedMovies.clear();
    _currentPage = 1;
    _hasReachedMax = false;
    _isLoadingMore = false;
    emit(HomeTopRatedInitial());
  }
}
