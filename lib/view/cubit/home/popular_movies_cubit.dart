import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../api_service/repository/movie_repository.dart';
import 'home_popular_state.dart';

class HomePopularCubit extends Cubit<HomePopularState> {
  final MovieRepository repository;
  HomePopularCubit(this.repository) : super(HomePopularInitial());

  int _currentPage = 1;
  List<Movie> _popularMovies = [];
  bool _isLoadingMore = false;

  List<Movie> get cachedPopularMovies => _popularMovies;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> fetchPopularMovies({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        emit(HomePopularLoading());
        _currentPage = 1;
        _popularMovies.clear();
      } else {
        if (_isLoadingMore) return;
        _isLoadingMore = true;
      }

      final newMovies = await repository.fetchPopularMovies(page: _currentPage);
      _currentPage++;

      _popularMovies.addAll(newMovies);
      emit(HomePopularLoaded(List.of(_popularMovies)));
    } catch (e) {
      emit(HomePopularError(e.toString()));
    } finally {
      _isLoadingMore = false;
    }
  }
}
