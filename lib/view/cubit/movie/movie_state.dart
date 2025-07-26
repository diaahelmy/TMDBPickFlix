import '../../../models/movie_model.dart';

abstract class MovieState {}

class MovieInitial extends MovieState {}

class MovieCombinedState extends MovieState {
  final List<Movie>? popularMovies;
  final List<Movie>? topRatedMovies;
  final bool isLoading;
  final String? error;

  MovieCombinedState({
    this.popularMovies,
    this.topRatedMovies,
    this.isLoading = false,
    this.error,
  });

  MovieCombinedState copyWith({
    List<Movie>? popularMovies,
    List<Movie>? topRatedMovies,
    bool? isLoading,
    String? error,
  }) {
    return MovieCombinedState(
      popularMovies: popularMovies ?? this.popularMovies,
      topRatedMovies: topRatedMovies ?? this.topRatedMovies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
