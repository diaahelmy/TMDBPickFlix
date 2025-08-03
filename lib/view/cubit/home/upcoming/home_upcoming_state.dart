import '../../../../models/movie_model.dart';

abstract class HomeUpcomingState {}

class HomeUpcomingInitial extends HomeUpcomingState {}
class HomeUpcomingLoading extends HomeUpcomingState {}
class HomeUpcomingLoaded extends HomeUpcomingState {
  final List<Movie> movies;
  HomeUpcomingLoaded(this.movies);
}
class HomeUpcomingError extends HomeUpcomingState {
  final String message;
  HomeUpcomingError(this.message);
}