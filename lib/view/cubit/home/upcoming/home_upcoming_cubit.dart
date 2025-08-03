import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../api_service/repository/movie_repository.dart';
import 'home_upcoming_state.dart';



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