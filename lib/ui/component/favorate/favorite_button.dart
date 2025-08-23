// favorite_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../../models/movie_detail_model.dart';
import '../../../models/search_result.dart';
import '../../../view/cubit/favorites/favorites_cubit.dart';
import '../../../view/cubit/favorites/favorites_state.dart';

class FavoriteButton extends StatefulWidget {
  final Movie? movie;
  final MovieDetail? movieDetail;
  final bool isLarge; // ✅ للتحكم في الحجم

  const FavoriteButton({
    super.key,
    this.movie,
    this.movieDetail,
    this.isLarge = false, // ✅ default صغير للكاردز
  }) : assert(
  movie != null || movieDetail != null,
  'Either movie or movieDetail must be provided',
  );

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final favoritesCubit = context.read<FavoritesCubit>();

        final movieId = widget.movie?.id ?? widget.movieDetail!.id;
        final isFavorite =
        favoritesCubit.cachedFavorites.any((m) => m.id == movieId);

        final movieToSave = widget.movie ?? _movieDetailToMovie(widget.movieDetail!);

        // ✅ أحجام مختلفة حسب المكان
        final containerSize = widget.isLarge ? 44.0 : 28.0;
        final iconSize = widget.isLarge ? 24.0 : 16.0;
        final positionOffset = widget.isLarge ? 12.0 : 6.0;

        return Positioned(
          top: positionOffset,
          right: positionOffset,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) => _controller.reverse(),
              onTapCancel: () => _controller.reverse(),
              onTap: () async {
                final wasAlreadyFavorite = isFavorite;

                await favoritesCubit.toggleFavorite(
                  movieToSave,
                  isFavorite: !wasAlreadyFavorite,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        wasAlreadyFavorite
                            ? 'Removed from favorites'
                            : 'Added to favorites',
                      ),
                      backgroundColor: Colors.grey[800],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(milliseconds: 1200),
                    ),
                  );
                }
              },
              child: Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  color: widget.isLarge
                      ? Colors.black.withOpacity(0.7)
                      : Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: widget.isLarge
                      ? Border.all(color: Colors.white.withOpacity(0.2), width: 1)
                      : null,
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red[400] : Colors.white,
                  size: iconSize,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Movie _movieDetailToMovie(MovieDetail movieDetail) {
    final mediaType =
    movieDetail.runtime != null ? MediaType.movie.name : MediaType.tv.name;

    return Movie(
      id: movieDetail.id,
      title: movieDetail.title,
      overview: movieDetail.overview,
      posterPath: movieDetail.posterPath,
      voteAverage: movieDetail.voteAverage,
      type: mediaType,
    );
  }
}