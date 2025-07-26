import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api_service/repository/movie_repository.dart';
import '../../data/movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository repository;

  MovieBloc(this.repository) : super(MovieCombinedState()) {
    on<FetchPopularMovies>(_onFetchPopularMovies);
    on<FetchTopRatedMovies>(_onFetchTopRatedMovies);
  }

  Future<void> _onFetchPopularMovies(
      FetchPopularMovies event, Emitter<MovieState> emit) async {
    final currentState = state is MovieCombinedState ? state as MovieCombinedState : MovieCombinedState();
    emit(currentState.copyWith(isLoading: true));
    try {
      final movies = await repository.fetchPopularMovies();
      emit(currentState.copyWith(popularMovies: movies, isLoading: false));
    } catch (e) {
      emit(currentState.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onFetchTopRatedMovies(
      FetchTopRatedMovies event, Emitter<MovieState> emit) async {
    final currentState = state is MovieCombinedState ? state as MovieCombinedState : MovieCombinedState();
    emit(currentState.copyWith(isLoading: true));
    try {
      final movies = await repository.fetchTopRatedMovies();
      emit(currentState.copyWith(topRatedMovies: movies, isLoading: false));
    } catch (e) {
      emit(currentState.copyWith(error: e.toString(), isLoading: false));
    }
  }
}

