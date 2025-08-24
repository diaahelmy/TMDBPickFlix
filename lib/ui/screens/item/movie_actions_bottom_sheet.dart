import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../../view/cubit/favorites/favorites_cubit.dart';
import '../../../view/cubit/watchlist/watchlist_cubit.dart';

class MovieActionsBottomSheet extends StatelessWidget {
  final Movie movie;

  const MovieActionsBottomSheet({
    super.key,
    required this.movie,
  });

  static void show(BuildContext context, Movie movie) {
    // ✅ Haptic feedback عند الضغط المطول
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MovieActionsBottomSheet(movie: movie),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesCubit = context.read<FavoritesCubit>();
    final watchlistCubit = context.read<WatchlistCubit>();

    final isFavorite = favoritesCubit.cachedFavorites.any(
          (m) => m.id == movie.id && m.type == movie.type,
    );

    final isInWatchlist = watchlistCubit.cachedWatchlist.any(
          (m) => m.id == movie.id && m.type == movie.type,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ معلومات الفيلم
          _buildMovieHeader(theme),

          const Divider(height: 1),

          // ✅ قائمة الأكشن
          _buildActionsList(
              theme,
              isFavorite,
              isInWatchlist,
              favoritesCubit,
              watchlistCubit,
              context
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMovieHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // صورة الفيلم
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://image.tmdb.org/t/p/w200${movie.posterPath}',
              width: 60,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 90,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.movie,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // معلومات الفيلم
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        movie.type.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsList(
      ThemeData theme,
      bool isFavorite,
      bool isInWatchlist,
      FavoritesCubit favoritesCubit,
      WatchlistCubit watchlistCubit,
      BuildContext context,
      ) {
    return Column(
      children: [
        // إضافة/إزالة من المفضلة
        _buildActionTile(
          context: context,
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          iconColor: isFavorite ? Colors.red : null,
          title: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
          onTap: () async {
            Navigator.pop(context);
            await favoritesCubit.toggleFavorite(movie, isFavorite: !isFavorite);
            _showSnackBar(
              context,
              isFavorite ? 'Removed from favorites' : 'Added to favorites',
            );
          },
        ),

        // إضافة/إزالة من قائمة المشاهدة
        _buildActionTile(
          context: context,
          icon: isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
          iconColor: isInWatchlist ? Colors.blue : null,
          title: isInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
          onTap: () async {
            Navigator.pop(context);
            await watchlistCubit.toggleWatchlist(movie, isInWatchlist: !isInWatchlist);
            _showSnackBar(
              context,
              isInWatchlist ? 'Removed from watchlist' : 'Added to watchlist',
            );
          },
        ),

        // مشاهدة التفاصيل
        _buildActionTile(
          context: context,
          icon: Icons.info_outline,
          title: 'View Details',
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to movie details
            _showSnackBar(context, 'Opening movie details...');
          },
        ),

        // مشاركة
        _buildActionTile(
          context: context,
          icon: Icons.share_outlined,
          title: 'Share',
          onTap: () {
            Navigator.pop(context);
            _shareMovie(context);
          },
        ),

        // تقييم
        _buildActionTile(
          context: context,
          icon: Icons.star_outline,
          title: 'Rate Movie',
          onTap: () {
            Navigator.pop(context);
            _showRatingDialog(context);
          },
        ),

        // إلغاء
        _buildActionTile(
          context: context,
          icon: Icons.close,
          title: 'Cancel',
          onTap: () => Navigator.pop(context),
          isCancel: true,
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    bool isCancel = false,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isCancel
                    ? theme.colorScheme.error
                    : iconColor ?? theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isCancel
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _shareMovie(BuildContext context) {
    // TODO: Implement share functionality
    _showSnackBar(context, 'Sharing: ${movie.title}');
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _RatingDialog(movie: movie),
    );
  }
}

// ✅ Dialog للتقييم
class _RatingDialog extends StatefulWidget {
  final Movie movie;

  const _RatingDialog({required this.movie});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Rate ${widget.movie.title}',
        style: theme.textTheme.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How would you rate this ${widget.movie.type}?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1.0;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_outline,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _rating > 0 ? '${_rating.toInt()}/5 Stars' : 'Tap to rate',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _rating > 0
              ? () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Rated ${widget.movie.title}: ${_rating.toInt()}/5 stars'),
                backgroundColor: Colors.grey[800],
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
              : null,
          child: const Text('Rate'),
        ),
      ],
    );
  }
}