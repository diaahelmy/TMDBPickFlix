import 'package:flutter/material.dart';
import '../../../models/movie_model.dart';
import '../../../view/cubit/home/top_rate/home_toprated_cubit.dart';
import '../../../view/cubit/home/top_rate/home_toprated_state.dart';
import '../../component/ basecubit/paginated_movie_list_screen.dart';

class TopRateScreen extends StatelessWidget {
  const TopRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginatedMovieListScreen<HomeTopRatedCubit, HomeTopRatedState, Movie>(
      title: 'Top Rated Movies',
      getMovies: (cubit) => cubit.cachedTopRateMovies,
      fetchMovies: (cubit, {loadMore = false}) =>
          cubit.fetchTopRatedMovies(loadMore: loadMore),
      isLoading: (state) => state is HomeTopRatedLoading,
      isError: (state) => state is HomeTopRatedError,
      isLoadingMore: (cubit) => cubit.isLoadingMore,
      hasErrorLoadingMore: (cubit) => cubit.hasErrorLoadingMore,
    );
  }
}
