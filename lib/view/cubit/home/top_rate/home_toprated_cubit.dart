import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/movie_model.dart';
import '../../../api_service/repository/movie_repository.dart';
import 'home_toprated_state.dart';


class HomeTopRatedCubit extends Cubit<HomeTopRatedState> {
  final MovieRepository repository;

  HomeTopRatedCubit(this.repository) : super(HomeTopRatedInitial());

  int _currentPage = 1;
  final List<Movie> _toprateMovies = [];
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;

  bool hasErrorLoadingMore = false;

  List<Movie> get cachedTopRateMovies => _toprateMovies;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasReachedMax => _hasReachedMax;

    Future<void> fetchTopRatedMovies({bool loadMore = false}) async {
      try {
        if (_isLoadingMore && loadMore) return;
        if (loadMore && _hasReachedMax) return;

        hasErrorLoadingMore = false;

        if (!loadMore) {
          emit(HomeTopRatedLoading());
          _currentPage = 1;
          _toprateMovies.clear();
          _hasReachedMax = false;
          _isLoadingMore = false;
        } else {
          _isLoadingMore = true;
          emit(HomeTopRatedLoaded(List.of(_toprateMovies)));
        }

        final newMovies = await repository.fetchTopRatedMovies(page: _currentPage);

        if (newMovies.length < 20) {
          _hasReachedMax = true;
        }

        if (newMovies.isNotEmpty) {
          _toprateMovies.addAll(newMovies);
          _currentPage++;
        } else {
          _hasReachedMax = true;
        }

        emit(HomeTopRatedLoaded(List.of(_toprateMovies)));
      } catch (e) {
        debugPrint("❌ Error fetching popular movies: $e");


        if (loadMore) {
          hasErrorLoadingMore = true;
          emit(HomeTopRatedLoaded(List.of(_toprateMovies))); // don't show full-screen error
        } else {
          emit(HomeTopRatedError(e.toString()));
        }
      } finally {
        _isLoadingMore = false;
      }
    }

    // Method to refresh the data
    Future<void> refresh() async {
      await fetchTopRatedMovies(loadMore: false);
    }

    // Method to clear cache
    void clearCache() {
      _toprateMovies.clear();
      _currentPage = 1;
      _hasReachedMax = false;
      _isLoadingMore = false;
      emit(HomeTopRatedInitial());
    }
  }