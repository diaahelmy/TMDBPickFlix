import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/ui/component/no_internet/compact_noInternet_widget.dart';
import 'package:pick_flix/view/cubit/home/home_cubit.dart';
import 'package:pick_flix/view/cubit/home/home_state.dart';
import 'package:pick_flix/ui/component/loading_grid_widget.dart';
import 'package:pick_flix/ui/component/movie_grid.dart';
import '../../component/no_internet/no_internet_widget.dart';

class PopularScreen extends StatelessWidget {
  const PopularScreen({super.key});

  bool _onScrollNotification(
    ScrollNotification notification,
    BuildContext context,
    HomeState state,
  ) {
    if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200 &&
        state is HomePopularLoaded) {
      context.read<HomeCubit>().fetchHomePopularMovies(loadMore: true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Movies')),
      body: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (prev, curr) =>
            curr is HomePopularLoading ||
            curr is HomePopularLoaded ||
            curr is HomePopularError,
        builder: (context, state) {
          final cubit = context.read<HomeCubit>();
          final movies = cubit.cachedPopularMovies;
          final alreadyLoaded = cubit.cachedPopularMovies.isNotEmpty;

          // لو لسه مافيش داتا و مش ب تحميل، نبدأ نحمّل الداتا
          if (!alreadyLoaded && state is! HomePopularLoading&&
              state is! HomePopularError) {
            Future.microtask(() => cubit.fetchHomePopularMovies());
          }

          if (state is HomePopularLoading) {
            return const LoadingGridWidget();
          }
          // ✅ لو حصل Error ومفيش أي داتا متخزنة  نعرض NoInternetWidget
          if (state is HomePopularError && movies.isEmpty) {
            return NoInternetWidget(
              onRetry: () {
                context.read<HomeCubit>().fetchHomePopularMovies();
              },
            );
          }
          else if (state is HomePopularLoaded || state is HomePopularError) {
            final isLoadingMore = cubit.isLoadingMore;
            final loadMoreError = cubit.loadMoreError;
            final movies = cubit.cachedPopularMovies;

            return NotificationListener<ScrollNotification>(
              onNotification: (notif) =>
                  _onScrollNotification(notif, context, state),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MovieGrid(
                      movies: movies,
                      crossAxisCount: 2,
                      showDetails: true,
                    ),


                    //  (pagination)
                    if (isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      ),


                    // no internet
                    if (loadMoreError != null)
                      CompactNoInternetWidget(
                        onRetry: () {
                          context.read<HomeCubit>().fetchHomePopularMovies(
                            loadMore: true,
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          } else if (state is HomePopularError) {
            return NoInternetWidget(
              onRetry: () {
                context.read<HomeCubit>().fetchHomePopularMovies();
              },
            );
          } else {
            return const Center(child: Text('No data.'));
          }
        },
      ),
    );
  }
}
