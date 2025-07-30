import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/movie_model.dart';

class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  final Set<Movie>? selectedMovies;
  final Function(Movie)? onMovieTap;
  final int? itemLimit;
  final int crossAxisCount;
  final bool showDetails;
  final bool showDescription;

  const MovieGrid({
    super.key,
    required this.movies,
    this.selectedMovies,
    this.onMovieTap,
    this.itemLimit,
    this.crossAxisCount = 3,
    this.showDetails = false,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayed = itemLimit != null
        ? movies.take(itemLimit!).toList()
        : movies;

    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // حساب عدد الأعمدة ديناميكيًا
    int dynamicCrossAxisCount = crossAxisCount;
    if (crossAxisCount == 3) {
      dynamicCrossAxisCount = screenWidth > 1200
          ? 6
          : screenWidth > 900
          ? 5
          : screenWidth > 600
          ? 4
          : 3;
    }

    // حساب النسبة الطولية للبطاقة
    double aspectRatio = screenWidth < 400 ? 0.5 : 0.6;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayed.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: dynamicCrossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, i) {
        final movie = displayed[i];
        final isSel = selectedMovies?.contains(movie) ?? false;

        return GestureDetector(
          onTap: () => onMovieTap?.call(movie),
          child: AnimatedScale(
            scale: isSel ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Card(
              elevation: isSel ? 8 : 2,
              shadowColor: isSel
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSel
                    ? BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                )
                    : BorderSide.none,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Movie Poster
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Image.network(
                            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                            fit: BoxFit.contain, // أفضل للصور
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.movie,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Selection overlay
                          if (isSel)
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                            ),

                          // Check icon
                          if (isSel)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.check,
                                  color: theme.colorScheme.onPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Movie Title
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      movie.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.3,
                        color: isSel
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (showDescription)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        movie.overview,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (showDetails)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
