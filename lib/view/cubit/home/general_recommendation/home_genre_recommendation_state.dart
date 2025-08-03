import '../../../../models/movie_model.dart';

abstract class HomeGenreRecommendationState {}

class HomeGenreRecommendationInitial extends HomeGenreRecommendationState {}
class HomeGenreRecommendationLoading extends HomeGenreRecommendationState {}
class HomeGenreRecommendationLoaded extends HomeGenreRecommendationState {
  final List<Movie> movies;
  HomeGenreRecommendationLoaded(this.movies);
}
class HomeGenreRecommendationError extends HomeGenreRecommendationState {
  final String message;
  HomeGenreRecommendationError(this.message);
}