import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api_service/repository/movie_repository.dart';
import 'movie_detail_state.dart';

class MovieDetailCubit extends Cubit<MovieDetailState> {
  final MovieRepository repository;

  MovieDetailCubit(BuildContext context)
      : repository = context.read<MovieRepository>(),
        super(MovieDetailInitial());

  Future<void> fetchDetail(int id, {required String source}) async {
    emit(MovieDetailLoading());
    try {
      final result = await repository.getMovieDetails(id: id, source: source);
      emit(MovieDetailLoaded(result));
    } catch (_) {
      emit(MovieDetailError('Failed to load $source details.'));
    }
  }
}
