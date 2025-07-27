import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/view/cubit/home/home_cubit.dart';
import 'package:pick_flix/view/cubit/home/home_state.dart';
import 'package:pick_flix/ui/component/loading_grid_widget.dart';
import 'package:pick_flix/ui/component/movie_grid.dart';

class PopularScreen extends StatelessWidget {
  const PopularScreen({super.key});

  bool _onScrollNotification(
      ScrollNotification notification, BuildContext context, HomeState state) {
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

          // في حالة أول تحميل
          if (state is! HomePopularLoading && state is! HomePopularLoaded) {
            Future.microtask(() => cubit.fetchHomePopularMovies());
          }

          if (state is HomePopularLoading) {
            return const LoadingGridWidget();
          } else if (state is HomePopularLoaded) {
            final isLoadingMore = cubit.isLoadingMore;

            return NotificationListener<ScrollNotification>(
              onNotification: (notif) =>
                  _onScrollNotification(notif, context, state),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MovieGrid(
                      movies: state.movies,
                      crossAxisCount: 2,
                      showDetails: true,
                    ),
                    if (isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            );
          } else if (state is HomePopularError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No data.'));
          }
        },
      ),
    );
  }
}
