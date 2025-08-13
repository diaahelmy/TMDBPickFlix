import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../../view/cubit/home/top_rate/home_toprated_cubit.dart';
import '../../../view/cubit/home/top_rate/home_toprated_state.dart';
import '../../../view/cubit/tab_change/TabState.dart';
import '../../component/ basecubit/paginated_movie_list_screen.dart';

class TopRateScreen extends StatelessWidget {
  const TopRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginatedMovieListScreen<HomeTopRatedCubit, HomeTopRatedState, Movie>(
      title: 'Top Rated Movies',
      getMovies: (cubit) => cubit.cachedTopRatedMovies,
      fetchMovies: (cubit, {loadMore = false}) {
        final selectedTab = context.read<TabCubit>().state.selectedTab;

        return  cubit.fetchTopRatedMovies(selectedTab, loadMore: loadMore);
      },
      isLoading: (state) => state is HomeTopRatedLoading,
      isError: (state) => state is HomeTopRatedError,
      isLoadingMore: (cubit) => cubit.isLoadingMore,
      hasErrorLoadingMore: (cubit) => cubit.hasErrorLoadingMore,
    );
  }
}
