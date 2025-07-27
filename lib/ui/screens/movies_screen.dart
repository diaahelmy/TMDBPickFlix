import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ لازم عشان .w و .h و .sp
import '../../view/cubit/movie/movie_bloc.dart';
import '../../view/cubit/movie/movie_state.dart';
import '../../view/data/movie_event.dart';
import '../component/movie_grid.dart';
import '../component/section_title.dart';
import '../component/header_widget.dart';
import '../component/selection_status_widget.dart';
import '../component/loading_grid_widget.dart';
import '../component/error_widget.dart';
import '../component/bottom_button_widget.dart';
import 'genre_screen.dart';
import '../component/navigation_helper.dart';

class FavoritesSelectionScreen extends StatelessWidget {
  const FavoritesSelectionScreen({super.key});

  final int minimumSelection = 3;

  void _handleScroll(BuildContext context, ScrollNotification notification) {
    final state = context.read<MovieBloc>().state as MovieCombinedState;
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 200 &&
        !state.topRatedLoaded) {
      context.read<MovieBloc>().add(FetchTopRatedTv());
      context.read<MovieBloc>().add(MarkTopRatedLoaded());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<MovieBloc, MovieState>(
              builder: (context, state) {
                if (state is! MovieCombinedState) return const SizedBox();
                return HeaderWidget(
                  minimumSelection: minimumSelection,
                  currentSelection: state.selectedMovies.length,
                );
              },
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  _handleScroll(context, notification);
                  return true;
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h), // ✅ تم تحويل الأبعاد
                  child: BlocBuilder<MovieBloc, MovieState>(
                    builder: (context, state) {
                      if (state is! MovieCombinedState) {
                        return const LoadingGridWidget();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectionStatusWidget(
                            selectedCount: state.selectedMovies.length,
                            minimumSelection: minimumSelection,
                          ),
                          SizedBox(height: 24.h), // ✅ responsive spacing

                          // ✅ Top Rated Movies Section
                          if (state.topRatedMovies?.isNotEmpty ?? false) ...[
                            const SectionTitle(title: "Top Rated Movies"),
                            SizedBox(height: 8.h),
                            MovieGrid(
                              movies: state.topRatedMovies!,
                              itemLimit: 12,
                              selectedMovies: state.selectedMovies,
                              onMovieTap: (movie) {
                                context.read<MovieBloc>().add(
                                  ToggleMovieSelection(movie),
                                );
                              },
                            ),
                            if (state.isTopRatedLoading) ...[
                              const LoadingGridWidget(),
                            ],
                          ] else if (state.isTopRatedLoading) ...[
                            const LoadingGridWidget(),
                          ] else if (state.topRatedError != null) ...[
                            ErrorWidgetCustom(message: state.topRatedError!),
                          ],

                          SizedBox(height: 32.h),

                          // ✅ Top Rated TV Section
                          if (state.topRatedTv?.isNotEmpty ?? false) ...[
                            const SectionTitle(title: "Top Rated TV"),
                            SizedBox(height: 8.h),
                            MovieGrid(
                              movies: state.topRatedTv!,
                              itemLimit: 12,
                              selectedMovies: state.selectedMovies,
                              onMovieTap: (movie) {
                                context.read<MovieBloc>().add(
                                  ToggleMovieSelection(movie),
                                );
                              },
                            ),
                            SizedBox(height: 32.h),
                          ],
                          if (state.isTopRatedTvLoading) ...[
                            const LoadingGridWidget(),
                          ],
                          if (state.topRatedTvError != null) ...[
                            ErrorWidgetCustom(message: state.topRatedTvError!),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ✅ Bottom Button Widget
      bottomNavigationBar: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is! MovieCombinedState) return const SizedBox();
          final isEnabled = state.selectedMovies.length >= minimumSelection;

          return BottomButtonWidget(
            isEnabled: isEnabled,
            selectedCount: state.selectedMovies.length,
            minimumSelection: minimumSelection,
            onContinue: () {
              navigateAndFinish(context, const GenreScreen());
            },
          );
        },
      ),
    );
  }
}
