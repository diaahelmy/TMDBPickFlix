import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api_service/repository/movie_repository.dart';
import 'home_state.dart';

class HomeCubit extends  Cubit<HomeState>{
  final MovieRepository repository;

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

  Future<void> fetchHomePopularMovies() async {
    emit(HomePopularLoading());
    try {
      final movies = await repository.fetchPopularMovies();
      emit(HomePopularLoaded(movies));
    } catch (e) {
      emit(HomePopularError(e.toString()));
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