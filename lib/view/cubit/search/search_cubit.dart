import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/view/cubit/search/search_state.dart';

import '../../api_service/repository/movie_repository.dart';


class SearchCubit extends Cubit<SearchState> {
  final MovieRepository movieRepository;
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  SearchCubit({required this.movieRepository}) : super(SearchInitial());

  void searchMovies(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    // Add debouncing to avoid too many API calls
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final movies = await movieRepository.searchMovies(query, page: 1);

      if (movies.isEmpty) {
        emit(SearchEmpty(query: query));
      } else {
        emit(SearchSuccess(
          movies: movies,
          query: query,
          currentPage: 1,
          hasReachedMax: movies.length < 20, // TMDB returns 20 results per page
        ));
      }
    } catch (e) {
      emit(SearchError(
        message: _getErrorMessage(e),
        query: query,
      ));
    }
  }

  Future<void> loadMoreResults() async {
    final currentState = state;
    if (currentState is! SearchSuccess ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final newMovies = await movieRepository.searchMovies(
        currentState.query,
        page: currentState.currentPage + 1,
      );

      final allMovies = [...currentState.movies, ...newMovies];

      emit(SearchSuccess(
        movies: allMovies,
        query: currentState.query,
        currentPage: currentState.currentPage + 1,
        hasReachedMax: newMovies.length < 20,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      // You might want to show a snackbar or toast here
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    emit(SearchInitial());
  }

  void resetToInitial() {
    _debounceTimer?.cancel();
    emit(SearchInitial());
  }

  void retrySearch() {
    final currentState = state;
    if (currentState is SearchError && currentState.query != null) {
      _performSearch(currentState.query!);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Failed to host lookup')) {
      return 'No internet connection. Please check your network.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}