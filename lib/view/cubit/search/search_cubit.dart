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
    print('SearchCubit: searchMovies called with query: "$query"'); // Debug

    // Cancel previous timer
    _debounceTimer?.cancel();

    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      print('SearchCubit: Query is empty, emitting SearchInitial'); // Debug
      emit(SearchInitial());
      return;
    }

    print('SearchCubit: Setting up debounce timer for query: "$trimmedQuery"'); // Debug

    // Add debouncing to avoid too many API calls
    _debounceTimer = Timer(_debounceDuration, () {
      print('SearchCubit: Debounce timer triggered, performing search'); // Debug
      _performSearch(trimmedQuery);
    });
  }

  // Immediate search without debounce (for history selections)
  void searchMoviesImmediate(String query) {
    print('SearchCubit: searchMoviesImmediate called with query: "$query"'); // Debug

    // Cancel any pending debounced search
    _debounceTimer?.cancel();

    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      print('SearchCubit: Immediate query is empty, emitting SearchInitial'); // Debug
      emit(SearchInitial());
      return;
    }

    // Perform search immediately
    print('SearchCubit: Performing immediate search'); // Debug
    _performSearch(trimmedQuery);
  }

  Future<void> _performSearch(String query) async {
    print('SearchCubit: _performSearch called with query: "$query"'); // Debug

    if (query.trim().isEmpty) {
      print('SearchCubit: Query is empty in _performSearch, emitting SearchInitial'); // Debug
      emit(SearchInitial());
      return;
    }

    print('SearchCubit: Emitting SearchLoading'); // Debug
    emit(SearchLoading());

    try {
      print('SearchCubit: Calling movieRepository.searchMovies'); // Debug
      final movies = await movieRepository.searchMovies(query, page: 1);
      print('SearchCubit: Received ${movies.length} movies'); // Debug

      if (movies.isEmpty) {
        print('SearchCubit: No movies found, emitting SearchEmpty'); // Debug
        emit(SearchEmpty(query: query));
      } else {
        print('SearchCubit: Movies found, emitting SearchSuccess'); // Debug
        emit(SearchSuccess(
          movies: movies,
          query: query,
          currentPage: 1,
          hasReachedMax: movies.length < 20, // TMDB returns 20 results per page
        ));
      }
    } catch (e) {
      print('SearchCubit: Error occurred: $e'); // Debug
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
    print('SearchCubit: clearSearch called'); // Debug
    _debounceTimer?.cancel();
    emit(SearchInitial());
  }

  void resetToInitial() {
    print('SearchCubit: resetToInitial called'); // Debug
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