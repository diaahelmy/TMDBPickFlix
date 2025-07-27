import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../view/cubit/home/home_cubit.dart';
import '../../view/cubit/home/home_state.dart';
import 'loading_grid_widget.dart';

class MovieSectionWidget extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final bool Function(HomeState) buildWhen;
  final Widget Function(List<Movie>) movieBuilder;
  final VoidCallback onRetry;

  const MovieSectionWidget({
    super.key,
    required this.title,
    required this.onSeeAll,
    required this.buildWhen,
    required this.movieBuilder,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & See All
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // BlocBuilder for section content
        BlocBuilder<HomeCubit, HomeState>(
          buildWhen: (prev, current) => buildWhen(current),
          builder: (context, state) {
            if (state is HomePopularLoading ||
                state is HomeUpcomingLoading ||
                state is HomeTopRateLoading) {
              return const LoadingGridWidget(); // already defined by you
            } else if (state is HomePopularLoaded ||
                state is HomeUpcomingLoaded ||
                state is HomeTopRateLoaded) {
              final movies = (state as dynamic).movies as List<Movie>;
              return movieBuilder(movies);
            } else if (state is HomePopularError ||
                state is HomeUpcomingError ||
                state is HomeTopRateError) {
              return _buildError(context);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Failed to load $title',
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
