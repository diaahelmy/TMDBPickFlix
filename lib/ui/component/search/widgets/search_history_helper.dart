import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryHelper {
  static const String _key = 'search_history';
  static const int _maxHistoryItems = 10;


  static Future<void> addSearchTerm(String term) async {
    try {
      if (term.trim().isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_key) ?? <String>[];

      final trimmedTerm = term.trim();

      // Remove existing occurrence to avoid duplicates
      history.remove(trimmedTerm);

      // Add to the beginning (most recent first)
      history.insert(0, trimmedTerm);

      // Limit the history size
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      await prefs.setStringList(_key, history);
    } catch (e) {
      // Log error but don't throw to avoid breaking the search functionality
      print('Error adding search term: $e');
    }
  }

  /// Retrieves the search history list
  /// Returns an empty list if no history exists or on error
  static Future<List<String>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_key) ?? <String>[];
    } catch (e) {
      print('Error getting search history: $e');
      return <String>[];
    }
  }

  /// Clears all search history
  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  /// Removes a specific term from the search history
  static Future<void> removeTerm(String term) async {
    try {
      if (term.trim().isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_key) ?? <String>[];

      history.remove(term.trim());
      await prefs.setStringList(_key, history);
    } catch (e) {
      print('Error removing search term: $e');
    }
  }

  /// Checks if a term exists in the search history
  static Future<bool> containsTerm(String term) async {
    try {
      if (term.trim().isEmpty) return false;

      final history = await getSearchHistory();
      return history.contains(term.trim());
    } catch (e) {
      print('Error checking if term exists: $e');
      return false;
    }
  }

  /// Gets the most recent search terms up to a specified limit
  static Future<List<String>> getRecentSearches([int limit = 5]) async {
    try {
      final history = await getSearchHistory();
      return history.take(limit).toList();
    } catch (e) {
      print('Error getting recent searches: $e');
      return <String>[];
    }
  }

  /// Updates the position of an existing term (moves it to the top)
  /// Useful when a user selects a term from history
  static Future<void> updateTermPosition(String term) async {
    try {
      if (term.trim().isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_key) ?? <String>[];

      final trimmedTerm = term.trim();

      // Remove the term if it exists
      history.remove(trimmedTerm);

      // Add it to the beginning
      history.insert(0, trimmedTerm);

      await prefs.setStringList(_key, history);
    } catch (e) {
      print('Error updating term position: $e');
    }
  }
}