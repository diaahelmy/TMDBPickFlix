import '../../../models/Genrel.dart';

class StateSplitScreen {
  final List<Genre> movieGenres;
  final List<Genre> tvGenres;

  StateSplitScreen({
    required this.movieGenres,
    required this.tvGenres,
  });

  StateSplitScreen copyWith({
    List<Genre>? movieGenres,
    List<Genre>? tvGenres,
  }) {
    return StateSplitScreen(
      movieGenres: movieGenres ?? this.movieGenres,
      tvGenres: tvGenres ?? this.tvGenres,
    );
  }
}
