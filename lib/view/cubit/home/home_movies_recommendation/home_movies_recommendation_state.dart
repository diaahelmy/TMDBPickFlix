import '../../../../models/movie_model.dart';

abstract class HomeMoviesRecommendationState {}

class HomeSelectedRecommendationInitial extends HomeMoviesRecommendationState {}

class HomeSelectedRecommendationLoading extends HomeMoviesRecommendationState {}

class HomeSelectedRecommendationLoaded extends HomeMoviesRecommendationState {
  final List<Movie> movies;
  final String? sourceTitle;

  HomeSelectedRecommendationLoaded(this.movies, this.sourceTitle);
}

class HomeSelectedRecommendationError extends HomeMoviesRecommendationState {
  final String message;

  HomeSelectedRecommendationError(this.message);
}