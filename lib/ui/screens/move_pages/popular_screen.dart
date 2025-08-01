import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/ui/component/no_internet/compact_noInternet_widget.dart';
import 'package:pick_flix/ui/component/loading_grid_widget.dart';
import 'package:pick_flix/ui/component/grid_item/movie_grid.dart';
import '../../../view/cubit/home/home_popular_state.dart';
import '../../../view/cubit/home/popular_movies_cubit.dart';
import '../../component/no_internet/no_internet_widget.dart';

class PopularScreen extends StatelessWidget {
  const PopularScreen({super.key});

  bool _onScrollNotification(
      ScrollNotification notification,
      BuildContext context,
      HomePopularState state,
      ) {
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 200) {
      final cubit = context.read<HomePopularCubit>();
      if (!cubit.isLoadingMore && state is! HomePopularError) {
        cubit.fetchPopularMovies(loadMore: true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Movies')),
      body: BlocBuilder<HomePopularCubit, HomePopularState>(
        builder: (context, state) {
          debugPrint("📦 Popular state: $state");
          final cubit = context.read<HomePopularCubit>();
          final movies = cubit.cachedPopularMovies;
          final alreadyLoaded = movies.isNotEmpty;

          if (!alreadyLoaded &&
              state is! HomePopularLoading &&
              state is! HomePopularError) {
            Future.microtask(() => cubit.fetchPopularMovies());
          }

          if (state is HomePopularLoading && !alreadyLoaded) {
            return const LoadingGridWidget();
          }

          if (state is HomePopularError && !alreadyLoaded) {
            return NoInternetWidget(
              onRetry: () {
                cubit.fetchPopularMovies();
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
                    ),
                    if (isLoadingMore && !isErrorLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    if (isErrorLoadingMore)
                      CompactNoInternetWidget(
                        onRetry: () {
                          cubit.fetchPopularMovies(loadMore: true);
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
