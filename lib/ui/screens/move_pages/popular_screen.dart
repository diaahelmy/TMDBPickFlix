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
        notification.metrics.maxScrollExtent - 200) {
      context.read<HomeCubit>().fetchHomePopularMovies(loadMore: true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Movies')),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          debugPrint("📦 Popular state: $state");
          final cubit = context.read<HomeCubit>();
          final movies = cubit.cachedPopularMovies;
          final alreadyLoaded = movies.isNotEmpty;

          // تحميل مبدئي للداتا لو مش متخزنة ومفيش تحميل أو خطأ
          if (!alreadyLoaded &&
              state is! HomePopularLoading &&
              state is! HomePopularError) {
            Future.microtask(() => cubit.fetchHomePopularMovies());
          }

          if (state is HomePopularLoading && !alreadyLoaded) {
            return const LoadingGridWidget();
          }

          if (state is HomePopularError && !alreadyLoaded) {
            return NoInternetWidget(
              onRetry: () {
                context.read<HomeCubit>().fetchHomePopularMovies();
              },
            );
          }

          // طالما في أفلام متخزنة، اعرضها بغض النظر عن نوع الحالة
          if (alreadyLoaded) {
            final isLoadingMore = cubit.isLoadingMore;
            final loadMoreError = cubit.loadMoreError;

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
                      showDescription: true,
                    ),
                    if (isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      ),
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
          }

          // fallback نهائي
          return const Center(child: Text('No data.'));
        },
      ),
    );
  }
}
