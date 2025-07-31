import 'cache.dart';

class SelectedMovieWithSource {
  final int id;
  final String source; // "movie" أو "tv"

  SelectedMovieWithSource({required this.id, required this.source});

  @override
  String toString() => '$source|$id';

  factory SelectedMovieWithSource.fromString(String str) {
    final parts = str.split('|');
    return SelectedMovieWithSource(
      source: parts[0],
      id: int.parse(parts[1]),
    );
  }
}

class SelectedPreferencesHelper {
  static const _selectedGenresKey = 'selected_genres';
  static const _selectedItemsKey = 'selected_items'; // أفلام ومسلسلات

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

  // حفظ الأفلام/المسلسلات المختارة
  static Future<void> saveSelectedItems(List<SelectedMovieWithSource> items) async {
    await Cache.setStringList(
      key: _selectedItemsKey,
      value: items.map((e) => e.toString()).toList(), // ex: movie|123
    );
  }

  // استرجاع الأفلام/المسلسلات المختارة
  static Future<List<SelectedMovieWithSource>> getSelectedItems() async {
    final rawList = Cache.getStringList(_selectedItemsKey) ?? [];
    return rawList.map((str) => SelectedMovieWithSource.fromString(str)).toList();
  }
}
