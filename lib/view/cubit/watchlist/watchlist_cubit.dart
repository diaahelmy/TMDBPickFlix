import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:pick_flix/models/movie_model.dart';
import '../../api_service/repository/movie_repository.dart';
import 'watchlist_state.dart';

class WatchlistCubit extends Cubit<WatchlistState> {
  final MovieRepository repository;
  final int accountId;
  final String sessionId;

  WatchlistCubit(this.repository, this.accountId, this.sessionId)
      : super(WatchlistInitial()) {
    fetchWatchlist(mediaType: "movies");
  }

  int _currentPage = 1;
  final List<Movie> _watchlist = [];
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;
  bool hasErrorLoadingMore = false;

  List<Movie> get cachedWatchlist => _watchlist;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasReachedMax => _hasReachedMax;

  Future<void> fetchWatchlist({
    bool loadMore = false,
    required String mediaType,
    int batchSize = 60,
  }) async {
    try {
      if (_isLoadingMore && loadMore) return;
      if (loadMore && _hasReachedMax) return;

      hasErrorLoadingMore = false;

      if (!loadMore) {
        emit(WatchlistLoading());
        _currentPage = 1;
        _watchlist.clear();
        _hasReachedMax = false;
        _isLoadingMore = false;
      } else {
        _isLoadingMore = true;
        emit(WatchlistLoaded(List.of(_watchlist)));
      }

      final List<Movie> batchItems = [];

      while (batchItems.length < batchSize) {
        final newItems = await repository.fetchWatchlist(
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
        _watchlist.addAll(batchItems);
      }

      emit(WatchlistLoaded(List.of(_watchlist)));
    } catch (e) {
      debugPrint("❌ Error fetching watchlist: $e");
      if (loadMore) {
        hasErrorLoadingMore = true;
        emit(WatchlistLoaded(List.of(_watchlist)));
      } else {
        emit(WatchlistError(e.toString()));
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh({required String mediaType}) async {
    await fetchWatchlist(loadMore: false, mediaType: mediaType);
  }

  void clearCache() {
    _watchlist.clear();
    _currentPage = 1;
    _hasReachedMax = false;
    _isLoadingMore = false;
    emit(WatchlistInitial());
  }

  Future<void> toggleWatchlist(Movie movie, {required bool isInWatchlist}) async {
    try {
      final mediaType = movie.type;

      await repository.toggleWatchlist(
        accountId: accountId,
        sessionId: sessionId,
        mediaId: movie.id,
        mediaType: mediaType,
        watchlist: isInWatchlist,
      );

      if (isInWatchlist) {
        if (!_watchlist.any((m) => m.id == movie.id && m.type == movie.type)) {
          _watchlist.insert(0, movie.copyWith(type: mediaType));
        }
      } else {
        _watchlist.removeWhere((m) => m.id == movie.id && m.type == movie.type);
      }

      emit(WatchlistLoaded(List.of(_watchlist)));
    } catch (e) {
      debugPrint("❌ Error toggling watchlist: $e");
      emit(WatchlistError("Failed to update watchlist"));
    }
  }
}
