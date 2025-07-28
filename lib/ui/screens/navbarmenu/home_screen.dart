import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/ui/component/navigation_helper.dart';
import '../../../view/cubit/home/home_cubit.dart';
import '../../../view/cubit/home/home_state.dart';
import '../../component/movie_grid.dart';
import '../../component/movie_section_widget.dart';
import '../move_pages/popular_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Pick Flix',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTabBar(context),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                ],
              ),
            ),
            const SizedBox(height: 16),
            MovieSectionWidget(
              title: 'Popular',
              onSeeAll: () {
                navigateTo(
                  context,
                  BlocProvider.value(
                    value: context.read<HomeCubit>(), // نفس الـ Cubit
                    child: const PopularScreen(),
                  ),
                );

              },
              buildWhen: (state) =>
              state is HomePopularLoading ||
                  state is HomePopularLoaded ||
                  state is HomePopularError,
              movieBuilder: (movies) =>
                  MovieGrid(movies: movies.take(6).toList()),
              onRetry: () =>
                  context.read<HomeCubit>().fetchHomePopularMovies(),
            ),
            const SizedBox(height: 24),
            MovieSectionWidget(
              title: 'Upcoming',
              onSeeAll: () {},
              buildWhen: (state) =>
              state is HomeUpcomingLoading ||
                  state is HomeUpcomingLoaded ||
                  state is HomeUpcomingError,
              movieBuilder: (movies) =>
                  MovieGrid(movies: movies.take(6).toList()),
              onRetry: () =>
                  context.read<HomeCubit>().fetchHomeUpComingMovies(),
            ),
            const SizedBox(height: 24),
            MovieSectionWidget(
              title: 'Top Rated',
              onSeeAll: () {},
              buildWhen: (state) =>
              state is HomeTopRateLoading ||
                  state is HomeTopRateLoaded ||
                  state is HomeTopRateError,
              movieBuilder: (movies) =>
                  MovieGrid(movies: movies.take(6).toList()),
              onRetry: () =>
                  context.read<HomeCubit>().fetchHomeTopRatedMovies(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                'Movies',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'TV Shows',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_movies, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Movie Deal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D4C41),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shuffle, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Random Movie Pick!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
