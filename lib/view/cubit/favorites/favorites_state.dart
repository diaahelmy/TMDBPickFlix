import '../../../models/movie_model.dart';

abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Movie> movies;
  FavoritesLoaded(this.movies);
}

class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);
}
