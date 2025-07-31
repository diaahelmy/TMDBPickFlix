import '../../models/movie_model.dart';

abstract class MovieEvent {}

class FetchPopularMovies extends MovieEvent {}

class FetchTopRatedMovies extends MovieEvent {}

class FetchTopRatedTv extends MovieEvent {}

class FetchRecommendationsBySelectedMovies extends MovieEvent {}

class ToggleMovieSelection extends MovieEvent {
  final Movie movie;
  ToggleMovieSelection(this.movie);
}

class MarkTopRatedLoaded extends MovieEvent {}
