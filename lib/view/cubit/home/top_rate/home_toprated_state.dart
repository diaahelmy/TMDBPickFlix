import '../../../../models/movie_model.dart';

abstract class HomeTopRatedState {}

class HomeTopRatedInitial extends HomeTopRatedState {}
class HomeTopRatedLoading extends HomeTopRatedState {}
class HomeTopRatedLoaded extends HomeTopRatedState {
  final List<Movie> movies;
  HomeTopRatedLoaded(this.movies);
}
class HomeTopRatedError extends HomeTopRatedState {
  final String message;
  HomeTopRatedError(this.message);
}
