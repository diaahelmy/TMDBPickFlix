// search_result_grid_card.dart
import 'package:flutter/material.dart';
import '../../../../models/search_result.dart';
import '../../grid_item/base_grid.dart';


class SearchResultGridCard extends StatelessWidget {
  final SearchResult result;
  final bool isSelected;
  final bool showDetails;
  final bool showMediaType;
  final ValueChanged<SearchResult>? onTap;

  const SearchResultGridCard({
    super.key,
    required this.result,
    required this.isSelected,
    required this.showDetails,
    required this.showMediaType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onTap?.call(result),
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: isSelected ? 8 : 2,
          shadowColor: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImage(theme),
              _buildTitle(theme),
              if (showDetails && _shouldShowRating()) _buildRating(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    return Expanded(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Stack(
          children: [
            _buildNetworkImage(theme),
            if (isSelected) _buildSelectionOverlay(theme),
            if (showMediaType) _buildMediaTypeBadge(theme),
            if (isSelected) _buildCheckIcon(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImage(ThemeData theme) {
    if (result.posterPath == null) {
      return _buildFallbackIcon(theme);
    }

    return Image.network(
      'https://image.tmdb.org/t/p/w500${result.posterPath}',
      fit: result.mediaType == MediaType.person ? BoxFit.cover : BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _buildFallbackIcon(theme),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingIndicator(theme, loadingProgress);
      },
    );
  }

  Widget _buildFallbackIcon(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        _getMediaTypeIcon(),
        size: 48,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme, ImageChunkEvent progress) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: progress.expectedTotalBytes != null
              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
    );
  }

  Widget _buildMediaTypeBadge(ThemeData theme) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        decoration: BoxDecoration(
          color: _getMediaTypeColor().withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getMediaTypeIcon(),
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 2),
            Text(
              _getMediaTypeText(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckIcon(ThemeData theme) {
    return Positioned(
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
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        result.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          height: 1.3,
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

  Widget _buildRating(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            result.voteAverage.toStringAsFixed(1),
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  bool _shouldShowRating() {
    return result.mediaType != MediaType.person && result.voteAverage > 0;
  }

  IconData _getMediaTypeIcon() {
    return switch (result.mediaType) {
      MediaType.movie => Icons.movie,
      MediaType.tv => Icons.tv,
      MediaType.person => Icons.person,
    };
  }

  String _getMediaTypeText() {
    return switch (result.mediaType) {
      MediaType.movie => 'Movie',
      MediaType.tv => 'TV',
      MediaType.person => 'Person',
    };
  }

  Color _getMediaTypeColor() {
    return switch (result.mediaType) {
      MediaType.movie => Colors.blue,
      MediaType.tv => Colors.green,
      MediaType.person => Colors.orange,
    };
  }
}

class SearchResultGrid extends BaseGrid<SearchResult> {
  final bool showDetails;
  final bool showMediaType;

  const SearchResultGrid({
    super.key,
    required super.items,
    super.selectedItems,
    super.onItemTap,
    super.itemLimit,
    super.crossAxisCount = 2,
    this.showDetails = false,
    this.showMediaType = true,
  });

  @override
  Widget buildGridItem(BuildContext context, SearchResult result, bool isSelected, int index) {
    return SearchResultGridCard(
      result: result,
      isSelected: isSelected,
      showDetails: showDetails,
      showMediaType: showMediaType,
      onTap: onItemTap,
    );
  }
}
