import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../../view/cubit/home/popular/home_popular_state.dart';
import '../../../view/cubit/home/popular/popular_movies_cubit.dart';
import '../../../view/cubit/tab_change/TabState.dart';
import '../../component/ basecubit/paginated_movie_list_screen.dart';

class PopularScreen extends StatelessWidget {
  const PopularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginatedMovieListScreen<HomePopularCubit, HomePopularState, Movie>(
      title: 'Popular Movies',
      getMovies: (cubit) => cubit.cachedPopularMovies,
      fetchMovies: (cubit, {loadMore = false}) {
        final selectedTab = context.read<TabCubit>().state.selectedTab;

      return  cubit.fetchPopularMovies(selectedTab, loadMore: loadMore);
      },
      isLoading: (state) => state is HomePopularLoading,
      isError: (state) => state is HomePopularError,
      isLoadingMore: (cubit) => cubit.isLoadingMore,
      hasErrorLoadingMore: (cubit) => cubit.hasErrorLoadingMore,
    );
  }
}
