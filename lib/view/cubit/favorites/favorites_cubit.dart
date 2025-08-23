
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/models/movie_model.dart';
import '../../api_service/repository/movie_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final MovieRepository repository;
  final int accountId;
  final String sessionId;

  FavoritesCubit(this.repository, this.accountId, this.sessionId)
      : super(FavoritesInitial());

  int _currentPage = 1;
  final List<Movie> _favorites = [];
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;
  bool hasErrorLoadingMore = false;

  List<Movie> get cachedFavorites => _favorites;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasReachedMax => _hasReachedMax;

  Future<void> fetchFavorites({
    bool loadMore = false,
    required String mediaType,
    int batchSize = 60,
  }) async {
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

      final List<Movie> batchItems = [];

      // نجيب كذا صفحة لحد ما نوصل batchSize
      while (batchItems.length < batchSize) {
        final newItems = await repository.fetchFavorites(
          mediaType: mediaType,
          accountId: accountId,
          sessionId: sessionId,
          page: _currentPage,
        );

        if (newItems.isEmpty) {
          _hasReachedMax = true;
          break;
        }

        batchItems.addAll(newItems.map((m) => m.copyWith(type: mediaType)));

        if (newItems.length < 20) {
          _hasReachedMax = true;
          break;
        }

        _currentPage++;
      }

      if (batchItems.isNotEmpty) {
        _favorites.addAll(batchItems);
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


  Future<void> refresh({required String mediaType}) async {
    await fetchFavorites(loadMore: false, mediaType: mediaType);
  }

  void clearCache() {
    _favorites.clear();
    _currentPage = 1;
    _hasReachedMax = false;
    _isLoadingMore = false;
    emit(FavoritesInitial());
  }

  Future<void> toggleFavorite(Movie movie, {required bool isFavorite}) async {
    try {
      final mediaType = movie.type;

      await repository.toggleFavorite(
        accountId: accountId,
        sessionId: sessionId,
        mediaId: movie.id,
        mediaType: mediaType,
        favorite: isFavorite,
      );

      if (isFavorite) {
        if (!_favorites.any((m) => m.id == movie.id && m.type == movie.type)) {
          _favorites.insert(0, movie.copyWith(type: mediaType));
        }
      } else {
        _favorites.removeWhere((m) => m.id == movie.id && m.type == movie.type);
      }

      emit(FavoritesLoaded(List.of(_favorites)));
    } catch (e) {
      debugPrint("❌ Error toggling favorite: $e");
      emit(FavoritesError("Failed to update favorites"));
    }
  }
}
