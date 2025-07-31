import 'cache.dart';

class SelectedPreferencesHelper {
  static const _selectedGenresKey = 'selected_genres';
  static const _selectedMoviesKey = 'selected_movies';

  // حفظ التصنيفات المختارة
  static Future<void> saveSelectedGenres(List<int> genreIds) async {
    await Cache.setStringList(
      key: _selectedGenresKey,
      value: genreIds.map((e) => e.toString()).toList(),
    );
  }

  // استرجاع التصنيفات المختارة
  static List<int> getSelectedGenres() {
    final ids = Cache.getStringList(_selectedGenresKey);
    return ids?.map(int.parse).toList() ?? [];
  }

  // حفظ الأفلام المختارة
  static Future<void> saveSelectedMovies(List<int> movieIds) async {
    await Cache.setStringList(
      key: _selectedMoviesKey,
      value: movieIds.map((e) => e.toString()).toList(),
    );
  }

  // استرجاع الأفلام المختارة
  static List<int> getSelectedMovies() {
    final ids = Cache.getStringList(_selectedMoviesKey);
    return ids?.map(int.parse).toList() ?? [];
  }
}
