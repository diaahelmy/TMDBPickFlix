import 'package:flutter/material.dart';

class EnhancedMovieCard extends StatefulWidget {
  final dynamic movie;
  final bool isSelectable;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onSelectionChanged;

  const EnhancedMovieCard({
    super.key,
    required this.movie,
    this.isSelectable = false,
    this.isSelected = false,
    this.onTap,
    this.onSelectionChanged,
  });

  @override
  State<EnhancedMovieCard> createState() => _EnhancedMovieCardState();
}

class _EnhancedMovieCardState extends State<EnhancedMovieCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    if (widget.isSelectable) {
      widget.onSelectionChanged?.call();
    } else {
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: _handleTap,
              child: Stack(
                children: [
                  // Main Card Content
                  Card(
                    elevation: widget.isSelected ? 8 : 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: widget.isSelected
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
                          flex: 3,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
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
                              ),

                              // Selection Overlay
                              if (widget.isSelected)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      color: theme.colorScheme.primary.withOpacity(0.3),
                                    ),
                                  ),
                                ),

                              // Rating Badge
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        widget.movie.voteAverage.toStringAsFixed(1),
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
                            ],
                          ),
                        ),

                        // Movie Title and Info
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.movie.title,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    height: 1.2,
                                    color: widget.isSelected
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                if (widget.movie.releaseDate?.isNotEmpty == true)
                                  Text(
                                    _formatYear(widget.movie.releaseDate),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selection Indicator
                  if (widget.isSelectable)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isSelected
                              ? theme.colorScheme.primary
                              : Colors.white.withOpacity(0.9),
                          border: Border.all(
                            color: widget.isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: widget.isSelected
                            ? Icon(
                          Icons.check,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        )
                            : null,
                      ),
                    ),

                  // Hover Effect (for web/desktop)
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _handleTap,
                        splashColor: theme.colorScheme.primary.withOpacity(0.1),
                        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
                      ),
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

  String _formatYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final year = dateString.split('-')[0];
      return year;
    } catch (e) {
      return '';
    }
  }
}