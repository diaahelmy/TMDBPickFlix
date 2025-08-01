import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../api_service/repository/movie_repository.dart';
import '../../helper/SelectedPreferencesHelper.dart';
import 'home_movies_recommendation_cubit.dart';

abstract class HomeGenreRecommendationState {}

class HomeGenreRecommendationInitial extends HomeGenreRecommendationState {}
class HomeGenreRecommendationLoading extends HomeGenreRecommendationState {}
class HomeGenreRecommendationLoaded extends HomeGenreRecommendationState {
  final List<Movie> movies;
  HomeGenreRecommendationLoaded(this.movies);
}
class HomeGenreRecommendationError extends HomeGenreRecommendationState {
  final String message;
  HomeGenreRecommendationError(this.message);
}

class HomeGeneralRecommendationCubit extends Cubit<HomeGenreRecommendationState> {
  final MovieRepository repository;

  HomeGeneralRecommendationCubit(this.repository)
      : super(HomeGenreRecommendationInitial());

  String? lastRecommendationSourceTitle;

  Future<void> fetchRecommendationsBySelectedMovies(List<SelectedMovieWithSource> selectedItems) async {
    emit(HomeGenreRecommendationLoading());

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

      final sourceMovie = await repository.getMovieDetails(id: sourceId, source: sourceType);
      lastRecommendationSourceTitle = sourceMovie.title;
    } catch (e) {
      debugPrint('❌ Error fetching recommendations for $sourceType $sourceId: $e');
    }

    if (allRecommendations.isNotEmpty) {
      final uniqueMovies = {for (var m in allRecommendations) m.id: m}.values.toList();
      uniqueMovies.shuffle();
      emit(HomeGenreRecommendationLoaded(uniqueMovies));
    } else {
      emit(HomeGenreRecommendationError('No recommendations found'));
    }
  }
}