// import 'package:flutter/material.dart';
// import 'package:pick_flix/view/cubit/home/home_movies_recommendation/home_movies_recommendation_cubit.dart';
// import 'package:pick_flix/view/cubit/home/home_movies_recommendation/home_movies_recommendation_state.dart';
// import 'package:pick_flix/view/helper/SelectedPreferencesHelper.dart';
// import '../../../models/movie_model.dart';
// import '../../../models/search_result.dart';
// import '../../component/ basecubit/paginated_movie_list_screen.dart';
//
// class RecomndedMovieScreen extends StatelessWidget {
//   const RecomndedMovieScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     return PaginatedMovieListScreen<HomeMoviesRecommendationCubit, HomeMoviesRecommendationState, Movie>(
//       title: 'Recommended Movie Movies',
//       getMovies: (cubit) => cubit.cachedRecommendations,
//       fetchMovies: (cubit, {loadMore = false}) =>
//           cubit.fetchRecommendations(MediaType.movie.name as List<SelectedMovieWithSource>, loadMore: loadMore),
//       isLoading: (state) => state is HomeSelectedRecommendationLoading,
//       isError: (state) => state is HomeSelectedRecommendationError,
//       isLoadingMore: (cubit) => cubit.isLoadingMore,
//       hasErrorLoadingMore: (cubit) => false,
//     );
//   }
// }
