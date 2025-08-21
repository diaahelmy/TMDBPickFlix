import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/models/search_result.dart';
import '../../../../models/movie_model.dart';
import '../../api_service/repository/movie_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final MovieRepository repository;
  final int accountId;
  final String sessionId;

  FavoritesCubit(this.repository, this.accountId, this.sessionId) : super(FavoritesInitial());

  int _currentPage = 1;
  final List<Movie> _favorites = [];
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;
  bool hasErrorLoadingMore = false;

  List<Movie> get cachedFavorites => _favorites;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasReachedMax => _hasReachedMax;

  /// ✅ جلب الفيفوريت
  Future<void> fetchFavorites({bool loadMore = false}) async {
    try {
      if (_isLoadingMore && loadMore) return;
      if (loadMore && _hasReachedMax) return;

      hasErrorLoadingMore = false;

      if (!loadMore) {
        emit(FavoritesLoading());
        _currentPage = 1;
        _favorites.clear();
        _hasReachedMax = false;
        _isLoadingMore = false;
      } else {
        _isLoadingMore = true;
        emit(FavoritesLoaded(List.of(_favorites)));
      }

      final newMovies = await repository.fetchFavorites(
        accountId: accountId,
        sessionId: sessionId,
        page: _currentPage,
      );

      if (newMovies.length < 20) {
        _hasReachedMax = true;
      }

      if (newMovies.isNotEmpty) {
        _favorites.addAll(newMovies);
        _currentPage++;
      } else {
        _hasReachedMax = true;
      }

      emit(FavoritesLoaded(List.of(_favorites)));
    } catch (e) {
      debugPrint("❌ Error fetching favorites: $e");

      if (loadMore) {
        hasErrorLoadingMore = true;
        emit(FavoritesLoaded(List.of(_favorites)));
      } else {
        emit(FavoritesError(e.toString()));
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  /// ✅ تحديث البيانات (سحب للتحديث)
  Future<void> refresh() async {
    await fetchFavorites(loadMore: false);
  }

  /// ✅ مسح الكاش
  void clearCache() {
    _favorites.clear();
    _currentPage = 1;
    _hasReachedMax = false;
    _isLoadingMore = false;
    emit(FavoritesInitial());
  }

  Future<void> toggleFavoriteDynamic({
    required Movie movie, // أو MovieDetail لو حبيت تدعم MovieDetail
    required bool isFavorite,
  }) async {
    try {
      // هنا نفترض أن Movie يحتوي على type: "movie" أو "tv"
      final mediaType = (movie.type == "tv") ? "tv" : "movie";

      await repository.toggleFavorite(
        accountId: accountId,
        sessionId: sessionId,
        mediaId: movie.id,
        mediaType: mediaType,
        favorite: isFavorite,
      );

      if (isFavorite) {
        if (!_favorites.any((m) => m.id == movie.id)) {
          _favorites.insert(0, movie);
        }
      } else {
        _favorites.removeWhere((m) => m.id == movie.id);
      }

      emit(FavoritesLoaded(List.of(_favorites)));
    } catch (e) {
      debugPrint("❌ Error toggling favorite: $e");
      emit(FavoritesError("Failed to update favorites"));
    }
  }


}
