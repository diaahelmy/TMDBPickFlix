import 'dart:ui';
import 'package:flutter/material.dart';

enum MediaType { movie, tv, person }

class SearchResult {
  final int id;
  final String name;
  final String? posterPath;
  final MediaType mediaType;
  final double voteAverage;

  SearchResult({
    required this.id,
    required this.name,
    required this.posterPath,
    required this.mediaType,
    required this.voteAverage,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final typeString = json['media_type'];
    late MediaType mediaType;
    if (typeString == 'movie') {
      mediaType = MediaType.movie;
    } else if (typeString == 'tv') {
      mediaType = MediaType.tv;
    } else {
      mediaType = MediaType.person;
    }

    return SearchResult(
      id: json['id'],
      name: json['title'] ?? json['name'] ?? '',
      posterPath: json['poster_path'] ?? json['profile_path'],
      mediaType: mediaType,
      voteAverage: json['vote_average'] is num ? (json['vote_average'] as num).toDouble() : 0.0,
    );
  }
}

class SearchResultGrid extends StatelessWidget {
  final List<SearchResult> results;
  final Set<SearchResult>? selectedResults;
  final Function(SearchResult)? onResultTap;
  final int? itemLimit;
  final int crossAxisCount;
  final bool showDetails;
  final bool showMediaType;

  const SearchResultGrid({
    super.key,
    required this.results,
    this.selectedResults,
    this.onResultTap,
    this.itemLimit,
    this.crossAxisCount = 3,
    this.showDetails = false,
    this.showMediaType = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayed = itemLimit != null
        ? results.take(itemLimit!).toList()
        : results;

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
        final result = displayed[i];
        final isSel = selectedResults?.contains(result) ?? false;

        return GestureDetector(
          onTap: () => onResultTap?.call(result),
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
                  // Image (Poster/Profile)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          _buildImage(context, result, theme),

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

                          // Media type badge
                          if (showMediaType)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getMediaTypeColor(result.mediaType).withValues(alpha: 0.9),
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
                                      _getMediaTypeIcon(result.mediaType),
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      _getMediaTypeText(result.mediaType),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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

                  // Title/Name
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      result.name,
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

                  // Rating (only for movies and TV shows)
                  if (showDetails && result.mediaType != MediaType.person && result.voteAverage > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
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
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(BuildContext context, SearchResult result, ThemeData theme) {
    if (result.posterPath == null) {
      return Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          _getMediaTypeIcon(result.mediaType),
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    // Different base URLs for different media types
    String imageUrl;
    BoxFit boxFit;

    if (result.mediaType == MediaType.person) {
      imageUrl = 'https://image.tmdb.org/t/p/w500${result.posterPath}';
      boxFit = BoxFit.cover; // Better for profile photos
    } else {
      imageUrl = 'https://image.tmdb.org/t/p/w500${result.posterPath}';
      boxFit = BoxFit.contain; // Better for posters
    }

    return Image.network(
      imageUrl,
      fit: boxFit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            _getMediaTypeIcon(result.mediaType),
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
    );
  }

  IconData _getMediaTypeIcon(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.movie:
        return Icons.movie;
      case MediaType.tv:
        return Icons.tv;
      case MediaType.person:
        return Icons.person;
    }
  }

  String _getMediaTypeText(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.movie:
        return 'Movie';
      case MediaType.tv:
        return 'TV';
      case MediaType.person:
        return 'Person';
    }
  }

  Color _getMediaTypeColor(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.movie:
        return Colors.blue;
      case MediaType.tv:
        return Colors.green;
      case MediaType.person:
        return Colors.orange;
    }
  }
}