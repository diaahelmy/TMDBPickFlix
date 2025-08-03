import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../api_service/repository/movie_repository.dart';
import 'home_toprated_state.dart';


class HomeTopRatedCubit extends Cubit<HomeTopRatedState> {
  final MovieRepository repository;

  HomeTopRatedCubit(this.repository) : super(HomeTopRatedInitial());

  Future<void> fetchTopRatedMovies() async {
    emit(HomeTopRatedLoading());
    try {
      final movies = await repository.fetchTopRatedMovies();
      emit(HomeTopRatedLoaded(movies));
    } catch (e) {
      emit(HomeTopRatedError(e.toString()));
    }
  }
}

