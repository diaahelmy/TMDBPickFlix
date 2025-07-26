import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api_service/repository/movie_repository.dart';
import '../../data/movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository repository;

  MovieBloc(this.repository) : super(MovieCombinedState()) {
    on<FetchPopularMovies>(_onFetchPopularMovies);
    on<FetchTopRatedMovies>(_onFetchTopRatedWatchAllTime);
  }
  Future<void> _onFetchPopularMovies(
      FetchPopularMovies event,
      Emitter<MovieState> emit,
      ) async {
    final currentState = state is MovieCombinedState
        ? state as MovieCombinedState
        : MovieCombinedState();

    // ✅ لو البيانات موجودة بالفعل، متعملش تحميل تاني
    if (currentState.popularMovies != null && currentState.popularMovies!.isNotEmpty) {
      return;
    }

    emit(currentState.copyWith(isPopularLoading: true));

    try {
      final movies = await repository.fetchPopularMovies();
      emit(
        currentState.copyWith(
          popularMovies: movies,
          isPopularLoading: false,
          popularError: null,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          popularError: e.toString(),
          isPopularLoading: false,
        ),
      );
    }
  }

  Future<void> _onFetchTopRatedWatchAllTime(
    FetchTopRatedMovies event,
    Emitter<MovieState> emit,
  ) async {
    final currentState = state is MovieCombinedState
        ? state as MovieCombinedState
        : MovieCombinedState();
    emit(currentState.copyWith(isTopRatedLoading: true));
    try {
      final movies = await repository.fetchTopRatedWatchAllTime();
      emit(
        currentState.copyWith(
          topRatedMovies: movies,
          isTopRatedLoading: false,
          topRatedError: null,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          topRatedError: e.toString(),
          isTopRatedLoading: false,
        ),
      );
    }
  }



}
