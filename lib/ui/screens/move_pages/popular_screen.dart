import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../../view/cubit/home/popular/home_popular_state.dart';
import '../../../view/cubit/home/popular/popular_movies_cubit.dart';
import '../../component/ basecubit/paginated_movie_list_screen.dart';
import '../../component/ basecubit/paginated_movies_cubit.dart';
import '../../component/ basecubit/paginated_movies_state.dart';

class PopularScreen extends StatelessWidget {
  const PopularScreen({super.key});

  @override
  Widget build(BuildContext context) {

     return PaginatedMovieListScreen<PaginatedMoviesCubit, PaginatedMoviesState, Movie>(
        title: 'Top Rated Movies',
        getMovies: (cubit) => cubit.cachedMovies,
        fetchMovies: (cubit, {loadMore = false}) =>
            cubit.fetchMovies(loadMore: loadMore),
        isLoading: (state) => state is PaginatedMoviesLoading,
        isError: (state) => state is PaginatedMoviesError,
        isLoadingMore: (cubit) => cubit.isLoadingMore,
        hasErrorLoadingMore: (cubit) => cubit.hasErrorLoadingMore,
      );
  }
}
