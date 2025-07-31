import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../api_service/repository/movie_repository.dart';

abstract class HomeUpcomingState {}

class HomeUpcomingInitial extends HomeUpcomingState {}
class HomeUpcomingLoading extends HomeUpcomingState {}
class HomeUpcomingLoaded extends HomeUpcomingState {
  final List<Movie> movies;
  HomeUpcomingLoaded(this.movies);
}
class HomeUpcomingError extends HomeUpcomingState {
  final String message;
  HomeUpcomingError(this.message);
}

class HomeUpcomingCubit extends Cubit<HomeUpcomingState> {
  final MovieRepository repository;

  HomeUpcomingCubit(this.repository) : super(HomeUpcomingInitial());

  Future<void> fetchUpcomingMovies() async {
    emit(HomeUpcomingLoading());
    try {
      final movies = await repository.fetchUpComingMovies();
      emit(HomeUpcomingLoaded(movies));
    } catch (e) {
      emit(HomeUpcomingError(e.toString()));
    }
  }
}