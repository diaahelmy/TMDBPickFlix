  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import '../../models/movie_model.dart';
  import '../../view/cubit/movie/movie_bloc.dart';
  import '../../view/cubit/movie/movie_state.dart';
  import '../../view/data/movie_event.dart';
  import '../component/movie_grid.dart';
  import '../component/section_title.dart';

  class MoviesScreen extends StatefulWidget {
    const MoviesScreen({super.key});

    @override
    State<MoviesScreen> createState() => _MoviesScreenState();
  }

  class _MoviesScreenState extends State<MoviesScreen> {
    bool topRatedLoaded = false;
    final Set<Movie> selectedMovies = {};

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

    void toggleSelection(Movie movie) {
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

      return Scaffold(
        appBar: AppBar(title: const Text("Choose Favorite Movies")),
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                _handleScroll(notification);
                return true;
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedMovies.length < 3
                          ? "Pick at least 3 movies to continue"
                          : "Great! You can continue",
                      style: TextStyle(
                        color: selectedMovies.length < 3
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// ✅ Popular Movies
                    const SectionTitle(title: "Popular Movies"),
                    BlocBuilder<MovieBloc, MovieState>(
                      builder: (context, state) {
                        if (state is MovieCombinedState) {
                          if (state.popularMovies != null &&
                              state.popularMovies!.isNotEmpty) {
                            return MovieGrid(
                              movies: state.popularMovies!,
                              itemLimit: 12,
                              selectedMovies: selectedMovies,
                              onMovieTap: toggleSelection,
                            );
                          } else if (state.isPopularLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state.popularError != null) {
                            return Text("Error: ${state.popularError}");
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    const SizedBox(height: 24),

                    /// ✅ Top Rated Movies
                    const SectionTitle(title: "Top Rated Watch All Time"),
                    BlocBuilder<MovieBloc, MovieState>(
                      builder: (context, state) {
                        if (state is MovieCombinedState) {
                          if (state.topRatedMovies != null &&
                              state.topRatedMovies!.isNotEmpty) {
                            return MovieGrid(
                              movies: state.topRatedMovies!,
                              itemLimit: 12,
                              selectedMovies: selectedMovies,
                              onMovieTap: toggleSelection,
                            );
                          } else if (state.isTopRatedLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state.topRatedError != null) {
                            return Text("Error: ${state.topRatedError}");
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),

            if (selectedMovies.length >= 3)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: FilledButton(
                  onPressed: () {
                    print("Selected Movies: ${selectedMovies.length}");
                  },
                  child: const Text("Next"),
                ),
              ),
          ],
        ),
      );
    }
  }
