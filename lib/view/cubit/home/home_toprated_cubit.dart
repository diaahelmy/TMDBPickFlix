import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../api_service/repository/movie_repository.dart';

abstract class HomeTopRatedState {}

class HomeTopRatedInitial extends HomeTopRatedState {}
class HomeTopRatedLoading extends HomeTopRatedState {}
class HomeTopRatedLoaded extends HomeTopRatedState {
  final List<Movie> movies;
  HomeTopRatedLoaded(this.movies);
}
class HomeTopRatedError extends HomeTopRatedState {
  final String message;
  HomeTopRatedError(this.message);
}

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

