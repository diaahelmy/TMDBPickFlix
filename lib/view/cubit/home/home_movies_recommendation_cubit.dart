import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../api_service/repository/movie_repository.dart';
import '../../helper/SelectedPreferencesHelper.dart';

abstract class HomeMoviesRecommendationState {}

class HomeSelectedRecommendationInitial extends HomeMoviesRecommendationState {}

class HomeSelectedRecommendationLoading extends HomeMoviesRecommendationState {}

class HomeSelectedRecommendationLoaded extends HomeMoviesRecommendationState {
  final List<Movie> movies;
  final String? sourceTitle;

  HomeSelectedRecommendationLoaded(this.movies, this.sourceTitle);
}

class HomeSelectedRecommendationError extends HomeMoviesRecommendationState {
  final String message;

  HomeSelectedRecommendationError(this.message);
}

class HomeMoviesRecommendationCubit extends Cubit<HomeMoviesRecommendationState> {
  final MovieRepository repository;

  HomeMoviesRecommendationCubit(this.repository) : super(HomeSelectedRecommendationInitial());

  String? lastRecommendationSourceTitle;

  Future<void> fetchRecommendations(List<SelectedMovieWithSource> selectedItems) async {
    emit(HomeSelectedRecommendationLoading());

    final allRecommendations = <Movie>[];
    lastRecommendationSourceTitle = null;

    selectedItems.shuffle();
    final selected = selectedItems.first;
    final int sourceId = selected.id;
    final String sourceType = selected.source;

    try {
      final recommendations = await repository.fetchSimilarMovies(
        id: sourceId,
        source: sourceType,
      );

      allRecommendations.addAll(recommendations);

      final sourceMovie = await repository.getMovieDetails(
        source: sourceType, id: sourceId,
      );
      lastRecommendationSourceTitle = sourceMovie.title;
    } catch (e) {
      debugPrint('❌ Error fetching recommendations for $sourceType $sourceId: $e');
    }

    if (allRecommendations.isNotEmpty) {
      final uniqueMovies = {for (var m in allRecommendations) m.id: m}.values.toList();
      uniqueMovies.shuffle();
      emit(HomeSelectedRecommendationLoaded(uniqueMovies, lastRecommendationSourceTitle));
    } else {
      emit(HomeSelectedRecommendationError('No recommendations found'));
    }
  }
}
