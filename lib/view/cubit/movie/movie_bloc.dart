import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../api_service/repository/movie_repository.dart';
import '../../data/movie_event.dart';
import '../../helper/SelectedPreferencesHelper.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository repository;
  final Set<Movie> selectedMovies = <Movie>{};
  bool topRatedLoaded = false;


  MovieBloc(this.repository) : super(MovieCombinedState()) {
    on<FetchTopRatedTv>(_onFetchTopRatedTv);
    on<FetchTopRatedMovies>(_onFetchTopRatedWatchAllTime);

    on<ToggleMovieSelection>((event, emit)async {
      final currentState = state as MovieCombinedState;
      final updatedSet = Set<Movie>.from(currentState.selectedMovies);

      if (updatedSet.contains(event.movie)) {
        updatedSet.remove(event.movie);
      } else {
        updatedSet.add(event.movie);
      }
      final selectedItems = updatedSet.map((movie) {
        final source = movie.title != null ? 'movie' : 'tv'; // مؤقتًا بناء على وجود title
        return SelectedMovieWithSource(id: movie.id, source: source);
      }).toList();

      await SelectedPreferencesHelper.saveSelectedItems(selectedItems);

      emit(currentState.copyWith(selectedMovies: updatedSet));
    });

    on<MarkTopRatedLoaded>((event, emit) {
      final currentState = state as MovieCombinedState;
      emit(currentState.copyWith(topRatedLoaded: true));
    });
  }

  Future<void> _onFetchTopRatedTv(
      FetchTopRatedTv event,
      Emitter<MovieState> emit,
      ) async {
    final currentState = state is MovieCombinedState
        ? state as MovieCombinedState
        : MovieCombinedState();

    if (currentState.topRatedTv != null && currentState.topRatedTv!.isNotEmpty) {
      return  ;
    }

    emit(currentState.copyWith(isTopRatedTvLoading: true));

    try {
      final movies = await repository.fetchTopRatedTv();

      emit(
        currentState.copyWith(
          topRatedTv: movies,
          isTopRatedTvLoading: false,
          topRatedTvError: null,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          topRatedTvError: e.toString(),
          isTopRatedTvLoading: false,
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
    if (currentState.topRatedMovies != null && currentState.topRatedMovies!.isNotEmpty) {
      return;
    }
    emit(currentState.copyWith(isTopRatedLoading: true));
    try {
      final movies = await repository.fetchTopRatedMovies();
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
