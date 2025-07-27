import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/ui/component/navigation_helper.dart';

import '../../models/movie_model.dart';
import '../../view/cubit/movie/movie_bloc.dart';
import '../../view/cubit/movie/movie_state.dart';
import '../../view/data/movie_event.dart';

// ✅ Widgets اللي فصلناها
import '../component/movie_grid.dart';
import '../component/section_title.dart';
import '../component/header_widget.dart';
import '../component/selection_status_widget.dart';
import '../component/loading_grid_widget.dart';
import '../component/error_widget.dart';
import '../component/bottom_button_widget.dart';
import 'genre_screen.dart';

class FavoritesSelectionScreen extends StatefulWidget {
  const FavoritesSelectionScreen({super.key});

  @override
  State<FavoritesSelectionScreen> createState() =>
      _FavoritesSelectionScreenState();
}

class _FavoritesSelectionScreenState extends State<FavoritesSelectionScreen> {
  final Set<Movie> selectedMovies = <Movie>{};
  final int minimumSelection = 3;
  bool topRatedLoaded = false;

  @override
  void initState() {
    super.initState();
    context.read<MovieBloc>().add(FetchPopularMovies());
  }

  void _handleScroll(ScrollNotification notification) {
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 200) {
      if (!topRatedLoaded) {
        context.read<MovieBloc>().add(FetchTopRatedMovies());
        setState(() {
          topRatedLoaded = true;
        });
      }
    }
  }

  void toggleMovieSelection(Movie movie) {
    setState(() {
      if (selectedMovies.contains(movie)) {
        selectedMovies.remove(movie);
      } else {
        selectedMovies.add(movie);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMinimumMet = selectedMovies.length >= minimumSelection;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            HeaderWidget(
              minimumSelection: minimumSelection,
              currentSelection: selectedMovies.length,
            ),

            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  _handleScroll(notification);
                  return true;
                },
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: BlocBuilder<MovieBloc, MovieState>(
                    builder: (context, state) {
                      if (state is MovieCombinedState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            SelectionStatusWidget(
                              selectedCount: selectedMovies.length,
                              minimumSelection: minimumSelection,
                            ),
                            const SizedBox(height: 24),

                            if (state.popularMovies != null &&
                                state.popularMovies!.isNotEmpty) ...[
                              const SectionTitle(title: "Popular Movies"),
                              const SizedBox(height: 8),
                              MovieGrid(
                                movies: state.popularMovies!,
                                itemLimit: 15,
                                selectedMovies: selectedMovies,
                                onMovieTap: toggleMovieSelection,
                              ),
                              const SizedBox(height: 32),
                            ] else if (state.isPopularLoading) ...[
                              const SectionTitle(title: "Popular Movies"),
                              const SizedBox(height: 16),

                              const LoadingGridWidget(),
                              const SizedBox(height: 32),
                            ],

                            if (state.topRatedMovies != null &&
                                state.topRatedMovies!.isNotEmpty) ...[
                              const SectionTitle(
                                  title: "Top Movies of All Time"),
                              const SizedBox(height: 8),
                              MovieGrid(
                                movies: state.topRatedMovies!,
                                itemLimit: 15,
                                selectedMovies: selectedMovies,
                                onMovieTap: toggleMovieSelection,
                              ),
                              const SizedBox(height: 32),
                            ] else if (state.isTopRatedLoading &&
                                topRatedLoaded) ...[
                              const SectionTitle(
                                  title: "Top Movies of All Time"),
                              const SizedBox(height: 16),
                              const LoadingGridWidget(),
                              const SizedBox(height: 32),
                            ],


                            if (state.popularError != null)
                              ErrorWidgetCustom(
                                  message:
                                  "Failed to load movies: ${state.popularError}"),

                            if (state.topRatedError != null)
                              ErrorWidgetCustom(
                                  message:
                                  "Failed to load popular movies: ${state.topRatedError}"),
                          ],
                        );
                      }


                      return Column(
                        children: [
                          SelectionStatusWidget(
                            selectedCount: selectedMovies.length,
                            minimumSelection: minimumSelection,
                          ),
                          const SizedBox(height: 24),
                          const SectionTitle(title: "Top Movies of All Time"),
                          const SizedBox(height: 16),
                          const LoadingGridWidget(),
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

      bottomNavigationBar: BottomButtonWidget(
        isEnabled: isMinimumMet,
        selectedCount: selectedMovies.length,
        minimumSelection: minimumSelection,
        onContinue: () {
          navigateAndFinish(context, GenreScreen());

        },
      ),
    );
  }
}
