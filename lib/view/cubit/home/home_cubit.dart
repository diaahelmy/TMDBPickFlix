import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api_service/repository/movie_repository.dart';
import '../../helper/SelectedPreferencesHelper.dart';
import 'home_state.dart';
import '../../../models/movie_model.dart';

class HomeCubit extends Cubit<HomeState> {
  final MovieRepository repository;
  HomePopularError? _loadMoreError;
  int _popularCurrentPage = 1;
  List<Movie> _popularMovies = [];
  bool isLoadingMore = false;

  int _genresCurrentPage = 1;
  int _selectedMoviesPage = 1;

  List<Movie> _genreRecommendedMovies = [];
  List<Movie> _selectedRecommendedMovies = [];

  bool isLoadingGenreMore = false;
  bool isLoadingSelectedMore = false;





  HomePopularError? get loadMoreError => _loadMoreError;
  List<Movie> get cachedPopularMovies => _popularMovies;

  HomeCubit(this.repository) : super(HomeInitial());

  Future<void> fetchHomeUpComingMovies() async {
    emit(HomeUpcomingLoading());
    try {
      final movies = await repository.fetchUpComingMovies();
      emit(HomeUpcomingLoaded(movies));
    } catch (e) {
      emit(HomeUpcomingError(e.toString()));
    }
  }
// داخل HomeCubit
  String? lastRecommendationSourceTitle;

  Future<void> fetchRecommendationsBySelectedMovies(List<int> movieIds) async {
    emit(HomeRecommendationsByMoviesLoading());

    final allRecommendations = <Movie>[];
    lastRecommendationSourceTitle = null;

    // اختار فيلم عشوائي
    movieIds.shuffle();
    final sourceMovieId = movieIds.first;

    try {
      final recommendations = await repository.fetchSimilarMovies(movieId: sourceMovieId);
      allRecommendations.addAll(recommendations);

      // ⬅️ هنا تجيب اسم الفيلم من الـ API
      final sourceMovie = await repository.getMovieDetails(sourceMovieId);
      lastRecommendationSourceTitle = sourceMovie.title;
    } catch (e) {
      debugPrint('❌ Error fetching recommendations for movie $sourceMovieId: $e');
    }

    if (allRecommendations.isNotEmpty) {
      final uniqueMovies = {for (var m in allRecommendations) m.id: m}.values.toList();
      uniqueMovies.shuffle();
      emit(HomeRecommendationsByMoviesLoaded(uniqueMovies));
    } else {
      emit(HomeRecommendationsByMoviesError('No recommendations found'));
    }
  }

  Future<void> fetchRecommendationsByGenres({required List<int> genreIds}) async {
    _genreRecommendedMovies.clear();
    emit(HomeRecommendationsByGenreLoading());

    if (genreIds.isEmpty) {
      emit(HomeRecommendationsByGenreLoaded([]));
      return;
    }

    final randomGenreId = (genreIds..shuffle()).first;

    try {
      final movies = await repository.fetchMoviesByGenres(genreIds: randomGenreId, page: 1);

      final randomMovie = (movies..shuffle()).take(1).toList();

      _genreRecommendedMovies = randomMovie;

      emit(HomeRecommendationsByGenreLoaded(randomMovie));
    } catch (e) {
      emit(HomeRecommendationsByGenreError(e.toString()));
    }
  }

  Future<void> fetchHomePopularMovies({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        if (isLoadingMore) return;

        _popularCurrentPage = 1;
        _loadMoreError = null; // Reset error عند أول تحميل

        emit(HomePopularLoading());
      } else {
        if (isLoadingMore) return;
        isLoadingMore = true;
        _popularCurrentPage++;

        emit(

          HomePopularLoaded(List.of(_popularMovies)),
        ); // لتحديث الـ UI بعلامة التحميل تحت
      }

      final newMovies = await repository.fetchPopularMovies(
        page: _popularCurrentPage,
      );

      if (loadMore) {
        _popularMovies.addAll(newMovies);
      } else {
        _popularMovies = newMovies;
      }
      _loadMoreError = null;


      emit(HomePopularLoaded(List.of(_popularMovies)));
    } catch (e) {
      if (loadMore) {
        _popularCurrentPage--; // ✅ ارجع الصفحة
        _loadMoreError = HomePopularError(e.toString()); // ✅ خزن الخطأ
        emit(HomePopularLoaded(List.of(_popularMovies))); // ✅ رجع مع البيانات
      }else{
        emit(HomePopularError(e.toString()));
      }
    } finally {
      isLoadingMore = false;
    }
  }

  Future<void> fetchHomeTopRatedMovies() async {
    emit(HomeTopRateLoading());
    try {
      final movies = await repository.fetchTopRatedMovies();
      emit(HomeTopRateLoaded(movies));
    } catch (e) {
      emit(HomeTopRateError(e.toString()));
    }
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    await fetchAllMovies();
  }

  Future<void> fetchAllMovies() async {
    await Future.wait([
      fetchHomePopularMovies(),
      fetchHomeUpComingMovies(),
      fetchHomeTopRatedMovies(),
    ]);
  }
}
