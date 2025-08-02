import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api_service/repository/movie_repository.dart';
import 'movie_detail_state.dart';

class MovieDetailCubit extends Cubit<MovieDetailState> {
  final MovieRepository _repository;

  MovieDetailCubit(BuildContext context)
      : _repository = context.read<MovieRepository>(),
        super(const MovieDetailInitial());

  Future<void> fetchDetail(int id, {required String source}) async {
    if (state is MovieDetailLoading) return; // Prevent multiple calls

    emit(const MovieDetailLoading());

    try {
      final movieDetail = await _repository.getMovieDetails(
        id: id,
        source: source,
      );

      if (!isClosed) {
        emit(MovieDetailLoaded(movieDetail));
      }
    } catch (error, stackTrace) {
      if (!isClosed) {
        // Log error for debugging
        debugPrint('Error fetching movie details: $error');
        debugPrint('Stack trace: $stackTrace');

        emit(MovieDetailError(_getErrorMessage(error, source)));
      }
    }
  }

  void retry(int id, {required String source}) {
    fetchDetail(id, source: source);
  }

  String _getErrorMessage(dynamic error, String source) {
    if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error.toString().contains('404')) {
      return 'Movie not found in $source database.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timeout. Please try again later.';
    } else {
      return 'Failed to load movie details from $source. Please try again.';
    }
  }
}