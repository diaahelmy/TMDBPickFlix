import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/ui/component/no_internet/compact_noInternet_widget.dart';
import 'package:pick_flix/ui/component/loading_grid_widget.dart';
import 'package:pick_flix/ui/component/grid_item/movie_grid.dart';
import '../../../models/search_result.dart';
import '../../../view/cubit/home/top_rate/home_toprated_cubit.dart';
import '../../../view/cubit/home/top_rate/home_toprated_state.dart';
import '../../component/navigation_helper.dart';
import '../../component/no_internet/no_internet_widget.dart';
import 'detail/movie_detail_screen.dart';

class TopRateScreen extends StatelessWidget {
  const TopRateScreen({super.key});

  bool _onScrollNotification(
      ScrollNotification notification,
      BuildContext context,
      HomeTopRatedState state,
      ) {
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 200) {
      final cubit = context.read<HomeTopRatedCubit>();
      if (!cubit.isLoadingMore && state is! HomeTopRatedError) {
        cubit.fetchTopRatedMovies(loadMore: true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TopRate Movies')),
      body: BlocBuilder<HomeTopRatedCubit, HomeTopRatedState>(
        builder: (context, state) {
          debugPrint("📦 TopRate state: $state");
          final cubit = context.read<HomeTopRatedCubit>();
          final movies = cubit.cachedTopRateMovies;
          final alreadyLoaded = movies.isNotEmpty;

          if (!alreadyLoaded &&
              state is! HomeTopRatedLoading &&
              state is! HomeTopRatedError) {
            Future.microtask(() => cubit.fetchTopRatedMovies());
          }

          if (state is HomeTopRatedLoading && !alreadyLoaded) {
            return const LoadingGridWidget();
          }

          if (state is HomeTopRatedError && !alreadyLoaded) {
            return NoInternetWidget(
              onRetry: () {
                cubit.fetchTopRatedMovies();
              },
            );
          }

          if (alreadyLoaded) {
            final isLoadingMore = cubit.isLoadingMore;
            final isErrorLoadingMore = cubit.hasErrorLoadingMore;

            return NotificationListener<ScrollNotification>(
              onNotification: (notif) =>
                  _onScrollNotification(notif, context, state),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MovieGrid(
                      items: movies,
                      crossAxisCount: 2,
                      showDetails: true,
                      showDescription: true,
                      onItemTap: (movie) {
                        navigateTo(
                          context,
                          MovieDetailScreen(
                            id: movie.id,
                            source: MediaType.movie.name, // MediaType.movie or MediaType.tv
                          ),
                        );
                      },
                    ),
                    if (isLoadingMore && !isErrorLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    if (isErrorLoadingMore)
                      CompactNoInternetWidget(
                        onRetry: () {
                          cubit.fetchTopRatedMovies(loadMore: true);
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
