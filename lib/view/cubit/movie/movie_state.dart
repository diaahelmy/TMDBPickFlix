import '../../../models/movie_model.dart';

abstract class MovieState {}

class MovieInitial extends MovieState {}

class MovieCombinedState extends MovieState {
  final List<Movie>? topRatedTv;
  final List<Movie>? topRatedMovies;
  final bool isTopRatedTvLoading;
  final bool isTopRatedLoading;
  final String? topRatedTvError;
  final String? topRatedError;

  final Set<Movie> selectedMovies;
  final bool topRatedLoaded;

  MovieCombinedState({
    this.topRatedTv,
    this.topRatedMovies,
    this.isTopRatedTvLoading = false,
    this.isTopRatedLoading = false,
    this.topRatedTvError,
    this.topRatedError,
    Set<Movie>? selectedMovies,
    this.topRatedLoaded = false,
  }) : selectedMovies = selectedMovies ?? {};


  MovieCombinedState copyWith({
    List<Movie>? topRatedTv,
    List<Movie>? topRatedMovies,
    bool? isTopRatedTvLoading,
    bool? isTopRatedLoading,
    String? topRatedTvError,
    String? topRatedError,
    Set<Movie>? selectedMovies,
    bool? topRatedLoaded,
  }) {
    return MovieCombinedState(
      topRatedTv: topRatedTv ?? this.topRatedTv,
      topRatedMovies: topRatedMovies ?? this.topRatedMovies,
      isTopRatedTvLoading: isTopRatedTvLoading ?? this.isTopRatedTvLoading,
      isTopRatedLoading: isTopRatedLoading ?? this.isTopRatedLoading,
      topRatedTvError: topRatedTvError ?? this.topRatedTvError,
      topRatedError: topRatedError ?? this.topRatedError,
      selectedMovies: selectedMovies ?? this.selectedMovies,
      topRatedLoaded: topRatedLoaded ?? this.topRatedLoaded,

    );
  }
}


