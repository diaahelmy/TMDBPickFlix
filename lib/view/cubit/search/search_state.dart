import 'package:equatable/equatable.dart';
import 'package:pick_flix/models/search_result.dart';

import '../../../ui/component/search/widgets/search_result_grid.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<SearchResult> results;
  final String query;
  final int currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const SearchSuccess({
    required this.results,
    required this.query,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  SearchSuccess copyWith({
    List<SearchResult>? results,
    String? query,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return SearchSuccess(
      results: results ?? this.results,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [results, query, currentPage, hasReachedMax, isLoadingMore];
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  final String message;
  final String? query;

  const SearchError({
    required this.message,
    this.query,
  });

  @override
  List<Object?> get props => [message, query];
}