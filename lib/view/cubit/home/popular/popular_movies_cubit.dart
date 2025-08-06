import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/movie_model.dart';
import '../../../api_service/repository/movie_repository.dart';
import '../../tab_change/TabState.dart';
import 'home_popular_state.dart';

class HomePopularCubit extends Cubit<HomePopularState> {
  final MovieRepository repository;
  HomePopularCubit(this.repository) : super(HomePopularInitial());

  int _currentPage = 1;
  final List<Movie> _popularMovies = [];
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;

  bool hasErrorLoadingMore = false;

  List<Movie> get cachedPopularMovies => _popularMovies;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasReachedMax => _hasReachedMax;

  /// ✅ جلب الأفلام أو المسلسلات الأكثر شعبية
  Future<void> fetchPopularMovies(ContentType type, {bool loadMore = false}) async {
    try {
      if (_isLoadingMore && loadMore) return;
      if (loadMore && _hasReachedMax) return;

      hasErrorLoadingMore = false;

      if (!loadMore) {
        emit(HomePopularLoading());
        _currentPage = 1;
        _popularMovies.clear();
        _hasReachedMax = false;
        _isLoadingMore = false;
      } else {
        _isLoadingMore = true;
        emit(HomePopularLoaded(List.of(_popularMovies)));
      }

      // ✅ تحديد المصدر بناءً على التبويب
      final source = type == ContentType.movie ? "movie" : "tv";

      final newMovies = await repository.fetchContent(
        source: source,
        category: "popular",
        page: _currentPage,
      );

      if (newMovies.length < 20) {
        _hasReachedMax = true;
      }

      if (newMovies.isNotEmpty) {
        _popularMovies.addAll(newMovies);
        _currentPage++;
      } else {
        _hasReachedMax = true;
      }

      emit(HomePopularLoaded(List.of(_popularMovies)));
    } catch (e) {
      debugPrint("❌ Error fetching popular movies: $e");

      if (loadMore) {
        hasErrorLoadingMore = true;
        emit(HomePopularLoaded(List.of(_popularMovies))); // لا تظهر خطأ ملء الشاشة
      } else {
        emit(HomePopularError(e.toString()));
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  /// ✅ تحديث البيانات (سحب للتحديث)
  Future<void> refresh(ContentType type) async {
    await fetchPopularMovies(type, loadMore: false);
  }

  /// ✅ مسح الكاش وإعادة الحالة الأساسية
  void clearCache() {
    _popularMovies.clear();
    _currentPage = 1;
    _hasReachedMax = false;
    _isLoadingMore = false;
    emit(HomePopularInitial());
  }
}
