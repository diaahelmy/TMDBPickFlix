  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:pick_flix/models/search_result.dart';
  import 'package:pick_flix/ui/component/navigation_helper.dart';
  import 'package:pick_flix/ui/screens/move_pages/up_coming_screen.dart';
import 'package:pick_flix/view/cubit/favorites/favorites_cubit.dart';
  import '../../../view/cubit/home/general_recommendation/home_genre_recommendation_cubit.dart';
  import '../../../view/cubit/home/home_movies_recommendation/home_movies_recommendation_cubit.dart';
  import '../../../view/cubit/home/home_movies_recommendation/home_movies_recommendation_state.dart';
  import '../../../view/cubit/home/popular/home_popular_state.dart';
  import '../../../view/cubit/home/top_rate/home_toprated_cubit.dart';
  import '../../../view/cubit/home/top_rate/home_toprated_state.dart';
  import '../../../view/cubit/home/upcoming/home_upcoming_cubit.dart';
  import '../../../view/cubit/home/popular/popular_movies_cubit.dart';
  import '../../../view/cubit/home/upcoming/home_upcoming_state.dart';
  import '../../../view/cubit/tab_change/TabState.dart';
  import '../../../view/helper/SelectedPreferencesHelper.dart';
  import '../../component/grid_item/movie_grid.dart';
  import '../../component/home_componant/build_action_buttons.dart';
  import '../../component/movie_section_widget.dart';
  import '../move_pages/detail/movie_detail_screen.dart';
  import '../move_pages/popular_screen.dart';
  import '../move_pages/top_rate_screen.dart';

  class HomeScreen extends StatelessWidget {
    const HomeScreen({super.key});

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      String _mapContentTypeToApi(ContentType type) {
        switch (type) {
          case ContentType.movie:
            return "movies"; // ✅ TMDB endpoint
          case ContentType.tv:
            return "tv";
        }
      }
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withOpacity(0.95),
                  ],
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildModernTabBar(context),
            ),
            centerTitle: true,
          ),
        ),
        body: BlocConsumer<TabCubit, TabState>(
          builder: (context, state) {
            return SingleChildScrollView(
              key: ValueKey(state.selectedTab),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        buildActionButtons(context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state.selectedTab == ContentType.movie)
                    _buildMoviesSections(context)
                  else
                    _buildTvSections(context),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
          listener: (BuildContext context, TabState state) {
            context.read<HomePopularCubit>().fetchPopularMovies(state.selectedTab);
            context.read<HomeUpcomingCubit>().fetchUpcomingMovies(state.selectedTab);
            context.read<HomeTopRatedCubit>().fetchTopRatedMovies(state.selectedTab);
            final mediaType = _mapContentTypeToApi(state.selectedTab);
            context.read<FavoritesCubit>().refresh(mediaType: mediaType);
          },
        ),
      );    }

    /// ✅ التاب بار
    Widget _buildModernTabBar(BuildContext context) {
      final theme = Theme.of(context);

      return BlocBuilder<TabCubit, TabState>(
        builder: (context, state) {
          return Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Sliding indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: state.selectedTab == ContentType.movie ? 4 : null,
                  right: state.selectedTab == ContentType.tv ? 4 : null,
                  top: 4,
                  bottom: 4,
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Tab buttons
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => context.read<TabCubit>().selectTab(ContentType.movie),
                          child: Container(
                            height: 48,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    state.selectedTab == ContentType.movie
                                        ? Icons.movie
                                        : Icons.movie_outlined,
                                    key: ValueKey(state.selectedTab == ContentType.movie),
                                    size: 18,
                                    color: state.selectedTab == ContentType.movie
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Movies',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: state.selectedTab == ContentType.movie
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontWeight: state.selectedTab == ContentType.movie
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => context.read<TabCubit>().selectTab(ContentType.tv),
                          child: Container(
                            height: 48,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    state.selectedTab == ContentType.tv
                                        ? Icons.tv
                                        : Icons.tv_outlined,
                                    key: ValueKey(state.selectedTab == ContentType.tv),
                                    size: 18,
                                    color: state.selectedTab == ContentType.tv
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'TV Shows',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: state.selectedTab == ContentType.tv
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontWeight: state.selectedTab == ContentType.tv
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    /// ✅ أقسام الأفلام
    Widget _buildMoviesSections(BuildContext context) {
      final recommendationCubit = context.watch<HomeMoviesRecommendationCubit>();
      final title = recommendationCubit.lastRecommendationSourceTitle;

      return Column(
        children: [
          MovieSectionWidget<HomeMoviesRecommendationCubit, HomeMoviesRecommendationState>(
            title: title != null ? 'Recommended (from "$title")' : 'Recommended',
            onSeeAll: () {},
            buildWhen: (state) =>
            state is HomeSelectedRecommendationLoading ||
                state is HomeSelectedRecommendationLoaded ||
                state is HomeSelectedRecommendationError,
            isLoading: (state) => state is HomeSelectedRecommendationLoading,
            isLoaded: (state) => state is HomeSelectedRecommendationLoaded,
            isError: (state) => state is HomeSelectedRecommendationError,
            getMovies: (state) => (state as HomeSelectedRecommendationLoaded).movies,
            movieBuilder: (movies) => MovieGrid(
              onFavoriteTap: (movie) {
                context.read<FavoritesCubit>().toggleFavorite(movie, isFavorite: true);
              },
              key: const ValueKey("movies_grid"),
              items: movies.take(6).toList(),
              showDetails: true,
              onItemTap: (movie) {
                final selectedTab = context.read<TabCubit>().state.selectedTab;

                navigateTo(context, MovieDetailScreen(
                  id: movie.id,
                  source: selectedTab == ContentType.movie
                      ? MediaType.movie.name
                      : MediaType.tv.name,
                ));
              },
            ),
            onRetry: () async {
              final selectedItems = await SelectedPreferencesHelper.getSelectedItems();
              context
                  .read<HomeGeneralRecommendationCubit>()
                  .fetchRecommendationsBySelectedMovies(selectedItems);
            },
          ),
          const SizedBox(height: 16),
          _buildPopularSection(context, ContentType.movie),
          const SizedBox(height: 24),
          _buildUpcomingSection(context, ContentType.movie),
          const SizedBox(height: 24),
          _buildTopRatedSection(context, ContentType.movie),
        ],
      );
    }

    /// ✅ أقسام TV Shows
    Widget _buildTvSections(BuildContext context) {
      return Column(
        children: [
          _buildPopularSection(context, ContentType.tv),
          const SizedBox(height: 24),
          _buildUpcomingSection(context, ContentType.tv),
          const SizedBox(height: 24),
          _buildTopRatedSection(context, ContentType.tv),
        ],
      );
    }

    /// ✅ الأقسام الأخرى (Popular / Upcoming / Top Rated)
    Widget _buildPopularSection(BuildContext context, ContentType type) {
      return MovieSectionWidget<HomePopularCubit, HomePopularState>(
        title: type == ContentType.movie ? 'Popular' : 'Popular TV Shows',
        onSeeAll: () => navigateTo(context, PopularScreen()),
        buildWhen: (state) =>
        state is HomePopularLoading || state is HomePopularLoaded || state is HomePopularError,
        isLoading: (state) => state is HomePopularLoading,
        isLoaded: (state) => state is HomePopularLoaded,
        isError: (state) => state is HomePopularError,
        getMovies: (state) => (state as HomePopularLoaded).movies,
        movieBuilder: (movies) => MovieGrid(
          key: ValueKey(type == ContentType.movie ? "popular_grid" : "popular_tv_grid"),
          items: movies.take(6).toList(),
          showDetails: true,
          onItemTap: (movie) {
            navigateTo(context, MovieDetailScreen(
              id: movie.id,
              source: type == ContentType.movie ? MediaType.movie.name : MediaType.tv.name,
            ));
          },
        ),
        onRetry: () => context.read<HomePopularCubit>().fetchPopularMovies(type),
      );
    }

    Widget _buildUpcomingSection(BuildContext context, ContentType type) {
      return MovieSectionWidget<HomeUpcomingCubit, HomeUpcomingState>(
        title: type == ContentType.movie ? 'Upcoming' : 'Upcoming TV Shows',
        onSeeAll: () => navigateTo(context, UpComingScreen()),
        buildWhen: (state) =>
        state is HomeUpcomingLoading || state is HomeUpcomingLoaded || state is HomeUpcomingError,
        isLoading: (state) => state is HomeUpcomingLoading,
        isLoaded: (state) => state is HomeUpcomingLoaded,
        isError: (state) => state is HomeUpcomingError,
        getMovies: (state) => (state as HomeUpcomingLoaded).movies,
        movieBuilder: (movies) => MovieGrid(
          key: ValueKey(type == ContentType.movie ? "upcoming_grid" : "upcoming_tv_grid"),
          items: movies.take(6).toList(),
          showDetails: true,
          onItemTap: (movie) {
            navigateTo(context, MovieDetailScreen(
              id: movie.id,
              source: type == ContentType.movie ? MediaType.movie.name : MediaType.tv.name,
            ));
          },
        ),
        onRetry: () => context.read<HomeUpcomingCubit>().fetchUpcomingMovies(type),
      );
    }

    Widget _buildTopRatedSection(BuildContext context, ContentType type) {
      return MovieSectionWidget<HomeTopRatedCubit, HomeTopRatedState>(
        title: type == ContentType.movie ? 'Top Rated' : 'Top Rated TV Shows',
        onSeeAll: () => navigateTo(context, TopRateScreen()),
        buildWhen: (state) =>
        state is HomeTopRatedLoading || state is HomeTopRatedLoaded || state is HomeTopRatedError,
        isLoading: (state) => state is HomeTopRatedLoading,
        isLoaded: (state) => state is HomeTopRatedLoaded,
        isError: (state) => state is HomeTopRatedError,
        getMovies: (state) => (state as HomeTopRatedLoaded).movies,
        movieBuilder: (movies) => MovieGrid(
          key: ValueKey(type == ContentType.movie ? "toprated_grid" : "toprated_tv_grid"),
          items: movies.take(6).toList(),
          showDetails: true,
          onItemTap: (movie) {
            navigateTo(context, MovieDetailScreen(
              id: movie.id,
              source: type == ContentType.movie ? MediaType.movie.name : MediaType.tv.name,
            ));
          },
        ),
        onRetry: () => context.read<HomeTopRatedCubit>().fetchTopRatedMovies(type),
      );
    }
  }
