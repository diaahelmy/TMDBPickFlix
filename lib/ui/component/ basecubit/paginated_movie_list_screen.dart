import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/ui/component/grid_item/movie_grid.dart';
import 'package:pick_flix/ui/component/loading_grid_widget.dart';
import 'package:pick_flix/ui/component/navigation_helper.dart';
import 'package:pick_flix/ui/component/no_internet/compact_noInternet_widget.dart';
import 'package:pick_flix/ui/component/no_internet/no_internet_widget.dart';
import '../../../models/movie_model.dart';
import '../../../models/search_result.dart';
import '../../screens/move_pages/detail/movie_detail_screen.dart';

class PaginatedMovieListScreen<TCubit extends Cubit<TState>, TState, TItem extends Movie>
    extends StatelessWidget {
  final String title;
  final List<TItem> Function(TCubit cubit) getMovies;
  final Future<void> Function(TCubit cubit, {bool loadMore}) fetchMovies;
  final bool Function(TState state) isLoading;
  final bool Function(TState state) isError;
  final bool Function(TCubit cubit) isLoadingMore;
  final bool Function(TCubit cubit) hasErrorLoadingMore;

  const PaginatedMovieListScreen({
    super.key,
    required this.title,
    required this.getMovies,
    required this.fetchMovies,
    required this.isLoading,
    required this.isError,
    required this.isLoadingMore,
    required this.hasErrorLoadingMore,
  });

  bool _onScrollNotification(
      ScrollNotification notification, TCubit cubit, TState state) {
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 200) {
      if (!isLoadingMore(cubit) && !isError(state)) {
        fetchMovies(cubit, loadMore: true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BlocBuilder<TCubit, TState>(
        builder: (context, state) {
          final cubit = context.read<TCubit>();
          final movies = getMovies(cubit);
          final alreadyLoaded = movies.isNotEmpty;

          if (!alreadyLoaded && !isLoading(state) && !isError(state)) {
            Future.microtask(() => fetchMovies(cubit));
          }

          if (isLoading(state) && !alreadyLoaded) {
            return const LoadingGridWidget();
          }

          if (isError(state) && !alreadyLoaded) {
            return NoInternetWidget(
              onRetry: () {
                fetchMovies(cubit);
              },
            );
          }

          if (alreadyLoaded) {
            return NotificationListener<ScrollNotification>(
              onNotification: (notif) => _onScrollNotification(notif, cubit, state),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MovieGrid(
                      items: movies, //  TItem extends Movie
                      crossAxisCount: 2,
                      showDetails: true,
                      showDescription: true,
                      onItemTap: (movie) {
                        navigateTo(
                          context,
                          MovieDetailScreen(
                            id: movie.id,
                            source: MediaType.movie.name,
                          ),
                        );
                      },
                    ),
                    if (isLoadingMore(cubit) && !hasErrorLoadingMore(cubit))
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    if (hasErrorLoadingMore(cubit))
                      CompactNoInternetWidget(
                        onRetry: () {
                          fetchMovies(cubit, loadMore: true);
                        },
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}
