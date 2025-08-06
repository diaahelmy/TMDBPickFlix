import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/models/search_result.dart';
import 'package:pick_flix/ui/component/navigation_helper.dart';
import 'package:pick_flix/ui/screens/move_pages/up_coming_screen.dart';
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/images/svgviewer.png',
            width: 100,
            height: 100,
          ),
          onPressed: () {},
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Pick Flix',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: BlocConsumer<TabCubit, TabState>(
        builder: (context, state) {
          return SingleChildScrollView(
            key: ValueKey(state.selectedTab),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTabBar(context),
                      const SizedBox(height: 24),
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
        }, listener: (BuildContext context, TabState state) {
        context.read<HomePopularCubit>().fetchPopularMovies(state.selectedTab);
        context.read<HomeUpcomingCubit>().fetchUpcomingMovies(state.selectedTab);
        context.read<HomeTopRatedCubit>().fetchTopRatedMovies(state.selectedTab);
      },
      ),
    );
  }

  /// ✅ التاب بار
  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TabCubit, TabState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.read<TabCubit>().selectTab(ContentType.movie),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: state.selectedTab == ContentType.movie
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: state.selectedTab == ContentType.movie
                          ? Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      )
                          : null,
                    ),
                    child: Text(
                      'Movies',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: state.selectedTab == ContentType.movie
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: state.selectedTab == ContentType.movie
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.read<TabCubit>().selectTab(ContentType.tv),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: state.selectedTab == ContentType.tv
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: state.selectedTab == ContentType.tv
                          ? Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      )
                          : null,
                    ),
                    child: Text(
                      'TV Shows',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: state.selectedTab == ContentType.tv
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: state.selectedTab == ContentType.tv
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
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
