import 'cache.dart';

class SelectedMovieWithSource {
  final int id;
  final String source; // "movie" أو "tv"

  SelectedMovieWithSource({
    required this.id,
    required this.source,
  });

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
  static const _selectedItemsKey = 'selected_items';

  /// حفظ التصنيفات
  static Future<void> saveSelectedGenres(List<int> genreIds) async {
    await Cache.saveData(
      key: _selectedGenresKey,
      value: genreIds.map((e) => e.toString()).toList(),
    );
  }

  /// استرجاع التصنيفات
  static List<int> getSelectedGenres() {
    final ids = Cache.getData(_selectedGenresKey) as List<String>?;
    return ids?.map(int.parse).toList() ?? [];
  }

  /// حفظ الأفلام/المسلسلات
  static Future<void> saveSelectedItems(List<SelectedMovieWithSource> items) async {
    await Cache.saveData(
      key: _selectedItemsKey,
      value: items.map((e) => e.toString()).toList(),
    );
  }

  /// استرجاع الأفلام/المسلسلات
  static List<SelectedMovieWithSource> getSelectedItems() {
    final rawList = Cache.getData(_selectedItemsKey) as List<String>? ?? [];
    return rawList.map((str) => SelectedMovieWithSource.fromString(str)).toList();
  }
}
