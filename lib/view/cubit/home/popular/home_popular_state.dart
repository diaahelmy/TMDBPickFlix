import '../../../../models/movie_model.dart';

abstract class HomePopularState {}

class HomePopularInitial extends HomePopularState {}

class HomePopularLoading extends HomePopularState {}

class HomePopularLoaded extends HomePopularState {
  final List<Movie> movies;

  HomePopularLoaded(this.movies);
}

class HomePopularError extends HomePopularState {
  final String message;

  HomePopularError(this.message);
}
