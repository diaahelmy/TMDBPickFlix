import '../../../models/movie_model.dart';

abstract  class HomeState {}

class HomeInitial extends HomeState {}

class HomeTopRateLoading extends HomeState {}

class HomeTopRateLoaded extends HomeState {
  final List<Movie> movies;
  HomeTopRateLoaded(this.movies);
}

class HomeTopRateError extends HomeState {
  final String message;
  HomeTopRateError(this.message);
}


class HomeUpcomingLoading extends HomeState {}

class HomeUpcomingLoaded extends HomeState {
  final List<Movie> movies;
  HomeUpcomingLoaded(this.movies);
}

class HomeUpcomingError extends HomeState {
  final String message;
  HomeUpcomingError(this.message);
}
class HomePopularLoading extends HomeState {}

class HomePopularLoaded extends HomeState {
  final List<Movie> movies;
  HomePopularLoaded(this.movies);
}

class HomePopularError extends HomeState {
  final String message;
  HomePopularError(this.message);
}


class HomeRecommendationsByGenreLoading extends HomeState {}
class HomeRecommendationsByGenreLoaded extends HomeState {
  final List<Movie> movies;
  HomeRecommendationsByGenreLoaded(this.movies);
}
class HomeRecommendationsByGenreError extends HomeState {
  final String error;
  HomeRecommendationsByGenreError(this.error);
}

class HomeRecommendationsByMoviesLoading extends HomeState {}
class HomeRecommendationsByMoviesLoaded extends HomeState {
  final List<Movie> movies;
  HomeRecommendationsByMoviesLoaded(this.movies);
}
class HomeRecommendationsByMoviesError extends HomeState {
  final String error;
  HomeRecommendationsByMoviesError(this.error);
}
