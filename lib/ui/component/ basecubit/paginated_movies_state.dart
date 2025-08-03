import '../../../models/movie_model.dart';

abstract class PaginatedMoviesState {}

class PaginatedMoviesInitial extends PaginatedMoviesState {}

class PaginatedMoviesLoading extends PaginatedMoviesState {}

class PaginatedMoviesLoaded extends PaginatedMoviesState {
  final List<Movie> movies;
  PaginatedMoviesLoaded(this.movies);
}

class PaginatedMoviesError extends PaginatedMoviesState {
  final String message;
  PaginatedMoviesError(this.message);
}