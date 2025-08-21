import 'package:flutter/cupertino.dart';

import '../../../models/movie_model.dart';
import '../../../view/cubit/favorites/favorites_cubit.dart';
import '../../../view/cubit/favorites/favorites_state.dart';
import '../../component/ basecubit/paginated_movie_list_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginatedMovieListScreen<FavoritesCubit, FavoritesState, Movie>(
      title: 'Favorite Movies',
      getMovies: (cubit) => cubit.cachedFavorites,
      fetchMovies: (cubit, {loadMore = false}) => cubit.fetchFavorites(loadMore: loadMore),
      isLoading: (state) => state is FavoritesLoading,
      isError: (state) => state is FavoritesError,
      isLoadingMore: (cubit) => cubit.isLoadingMore,
      hasErrorLoadingMore: (cubit) => cubit.hasErrorLoadingMore,
    );
  }
}
