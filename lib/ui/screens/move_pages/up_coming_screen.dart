import 'package:flutter/material.dart';
import '../../../models/movie_model.dart';
import '../../../view/cubit/home/upcoming/home_upcoming_cubit.dart';
import '../../../view/cubit/home/upcoming/home_upcoming_state.dart';
import '../../../view/cubit/tab_change/TabState.dart';
import '../../component/ basecubit/paginated_movie_list_screen.dart';

class UpComingScreen extends StatelessWidget {
  const UpComingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginatedMovieListScreen<HomeUpcomingCubit,HomeUpcomingState , Movie>(
      title: 'UpComing Movies',
      getMovies: (cubit) => cubit.cachedUpcomingMovies,
      fetchMovies: (cubit, {loadMore = false}) =>
          cubit.fetchUpcomingMovies(ContentType.movie ,loadMore: loadMore),
      isLoading: (state) => state is HomeUpcomingLoading,
      isError: (state) => state is HomeUpcomingError,
      isLoadingMore: (cubit) => cubit.isLoadingMore,
      hasErrorLoadingMore: (cubit) => cubit.hasErrorLoadingMore,
    );
  }
}
