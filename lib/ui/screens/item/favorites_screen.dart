import 'package:flutter/material.dart';
import '../../../models/movie_model.dart';
import '../../../models/search_result.dart';
import '../../../view/cubit/favorites/favorites_cubit.dart';
import '../../../view/cubit/favorites/favorites_state.dart';
import '../../component/ basecubit/paginated_movie_list_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final MediaType mediaType;

  const FavoritesScreen({super.key, required this.mediaType});

  @override
  Widget build(BuildContext context) {
    return PaginatedMovieListScreen<FavoritesCubit, FavoritesState, Movie>(
      title: mediaType == MediaType.movie
          ? 'Favorite Movies'
          : 'Favorite TV Shows',
      getMovies: (cubit) => cubit.cachedFavorites,
      fetchMovies: (cubit, {loadMore = false}) {
        return cubit.fetchFavorites(
          loadMore: loadMore,
          mediaType: mediaType.name,
        );
      },
      isLoading: (state) => state is FavoritesLoading,
      isError: (state) => state is FavoritesError,
      isLoadingMore: (cubit) => cubit.isLoadingMore,
      hasErrorLoadingMore: (cubit) => cubit.hasErrorLoadingMore,
      emptyWidget: Center(
        child: Text(
          mediaType == MediaType.movie
              ? "No favorite movies selected yet 🎬"
              : "No favorite TV shows selected yet 📺",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
