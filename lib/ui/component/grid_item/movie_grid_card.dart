import 'package:flutter/material.dart';
import '../../../../models/movie_model.dart';
import '../favorate/favorite_button.dart';

class MovieGridCard extends StatelessWidget {
  final Movie movie;
  final bool isSelected;
  final bool showDetails;
  final bool showDescription;

  /// ✅ callback عشان تتحكم في الـ favorite من الـ UI/Cubit
  final ValueChanged<Movie>? onTap;
  final ValueChanged<Movie>? onFavoriteTap;

  const MovieGridCard({
    super.key,
    required this.movie,
    required this.isSelected,
    required this.showDetails,
    required this.showDescription,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onTap?.call(movie),
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: isSelected ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPoster(theme, context),
              _buildTitle(theme),
              if (showDescription) _buildDescription(theme),
              if (showDetails) _buildRating(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster(ThemeData theme, BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Stack(
          children: [
            Image.network(
              'https://image.tmdb.org/t/p/w500${movie.posterPath}',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => _errorIcon(theme),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _loadingIndicator(theme, loadingProgress);
              },
            ),
            if (isSelected) _selectionOverlay(theme),
            if (isSelected) _checkIcon(theme),

            /// ✅ زرار المفضلة بيتحكم فيه الـ Cubit
            Positioned(
              top: 8,
              left: 8,
              child: FavoriteButton(
                movie: movie,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorIcon(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.movie,
        size: 48,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _loadingIndicator(ThemeData theme, ImageChunkEvent loadingProgress) {
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
  }

  Widget _selectionOverlay(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
    );
  }

  Widget _checkIcon(ThemeData theme) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        movie.title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Padding(
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
    );
  }

  Widget _buildRating(ThemeData theme) {
    return Padding(
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
    );
  }
}
