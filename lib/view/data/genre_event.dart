abstract class GenreEvent {}

class ToggleGenreSelection extends GenreEvent {
  final int genreId;

  ToggleGenreSelection(this.genreId);
}

class LoadGenres extends GenreEvent {}
