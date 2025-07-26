import '../../../models/movie_model.dart';

abstract class MovieState {}

class MovieInitial extends MovieState {}

class MovieCombinedState extends MovieState {
  final List<Movie>? popularMovies;
  final List<Movie>? topRatedMovies;
  final bool isPopularLoading;
  final bool isTopRatedLoading;
  final String? popularError;
  final String? topRatedError;

  MovieCombinedState({
    this.popularMovies,
    this.topRatedMovies,
    this.isPopularLoading = false,
    this.isTopRatedLoading = false,
    this.popularError,
    this.topRatedError,
  });

  MovieCombinedState copyWith({
    List<Movie>? popularMovies,
    List<Movie>? topRatedMovies,
    bool? isPopularLoading,
    bool? isTopRatedLoading,
    String? popularError,
    String? topRatedError,
  }) {
    return MovieCombinedState(
      popularMovies: popularMovies ?? this.popularMovies,
      topRatedMovies: topRatedMovies ?? this.topRatedMovies,
      isPopularLoading: isPopularLoading ?? this.isPopularLoading,
      isTopRatedLoading: isTopRatedLoading ?? this.isTopRatedLoading,
      popularError: popularError ?? this.popularError,
      topRatedError: topRatedError ?? this.topRatedError,
    );
  }
}


