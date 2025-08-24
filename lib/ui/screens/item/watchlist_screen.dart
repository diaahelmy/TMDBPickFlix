import 'package:flutter/material.dart';
import '../../../models/movie_model.dart';
import '../../../models/search_result.dart';
import '../../../view/cubit/watchlist/watchlist_cubit.dart';
import '../../../view/cubit/watchlist/watchlist_state.dart';
import '../../component/ basecubit/paginated_movie_list_screen.dart';

class WatchlistScreen extends StatelessWidget {
  final MediaType mediaType;

  const WatchlistScreen({super.key, required this.mediaType});

  @override
  Widget build(BuildContext context) {
    return PaginatedMovieListScreen<WatchlistCubit, WatchlistState, Movie>(
      title: mediaType == MediaType.movie
          ? 'Watchlist Movies'
          : 'Watchlist TV Shows',
      getMovies: (cubit) => cubit.cachedWatchlist,
      fetchMovies: (cubit, {loadMore = false}) {
        return cubit.fetchWatchlist(
          loadMore: loadMore,
          mediaType: mediaType.name,
        );
      },
      isLoading: (state) => state is WatchlistLoading,
      isError: (state) => state is WatchlistError,
      isLoadingMore: (cubit) => cubit.isLoadingMore,
      hasErrorLoadingMore: (cubit) => cubit.hasErrorLoadingMore,
      emptyWidget: Center(
        child: Text(
          mediaType == MediaType.movie
              ? "No movies in your watchlist yet ⏳"
              : "No TV shows in your watchlist yet 📺",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
