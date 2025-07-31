
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import 'loading_grid_widget.dart';

class MovieSectionWidget<C extends Cubit<S>, S> extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final bool Function(S) buildWhen;
  final Widget Function(List<Movie>) movieBuilder;
  final VoidCallback onRetry;

  /// New:
  final bool Function(S) isLoading;
  final bool Function(S) isLoaded;
  final bool Function(S) isError;
  final List<Movie> Function(S) getMovies;

  const MovieSectionWidget({
    super.key,
    required this.title,
    required this.onSeeAll,
    required this.buildWhen,
    required this.movieBuilder,
    required this.onRetry,

    // NEW required fields:
    required this.isLoading,
    required this.isLoaded,
    required this.isError,
    required this.getMovies,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + See All
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
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

        BlocBuilder<C, S>(
          buildWhen: (previous, current) => buildWhen(current),
          builder: (context, state) {
            if (isLoading(state)) {
              return const LoadingGridWidget();
            } else if (isLoaded(state)) {
              final movies = getMovies(state);
              return movieBuilder(movies);
            } else if (isError(state)) {
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