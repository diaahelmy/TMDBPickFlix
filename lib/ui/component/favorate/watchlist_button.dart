import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../../models/movie_detail_model.dart';
import '../../../view/cubit/watchlist/watchlist_cubit.dart';
import '../../../view/cubit/watchlist/watchlist_state.dart';

class WatchlistButton extends StatefulWidget {
  final Movie? movie;
  final MovieDetail? movieDetail;
  final bool isLarge; // ✅ للتحكم في الحجم

  const WatchlistButton({
    super.key,
    this.movie,
    this.movieDetail,
    this.isLarge = false, // ✅ default صغير للكاردز
  }) : assert(
  movie != null || movieDetail != null,
  'Either movie or movieDetail must be provided',
  );

  @override
  State<WatchlistButton> createState() => _WatchlistButtonState();
}

class _WatchlistButtonState extends State<WatchlistButton>
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
    return BlocBuilder<WatchlistCubit, WatchlistState>(
      builder: (context, state) {
        final watchlistCubit = context.read<WatchlistCubit>();

        final movieId = widget.movie?.id ?? widget.movieDetail!.id;
        final movieType = widget.movie?.type ??
            (widget.movieDetail?.runtime != null ? "movie" : "tv");

        // ✅ فحص إذا كان الفيلم في الـ Watchlist
        final isInWatchlist = watchlistCubit.cachedWatchlist.any(
              (m) => m.id == movieId && m.type == movieType,
        );

        final movieToSave = widget.movie ?? _movieDetailToMovie(widget.movieDetail!);

        // ✅ أحجام مختلفة حسب المكان
        final containerSize = widget.isLarge ? 44.0 : 32.0;
        final iconSize = widget.isLarge ? 22.0 : 18.0;
        final positionOffset = widget.isLarge ? 12.0 : 8.0;

        return Positioned(
          top: positionOffset,
          right: positionOffset, // ✅ تم تحويله لليمين بدلاً من اليسار
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) => _controller.reverse(),
              onTapCancel: () => _controller.reverse(),
              onTap: () async {
                final wasAlreadyInWatchlist = isInWatchlist;

                await watchlistCubit.toggleWatchlist(
                  movieToSave,
                  isInWatchlist: !wasAlreadyInWatchlist,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        wasAlreadyInWatchlist
                            ? 'Removed from watchlist'
                            : 'Added to watchlist',
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
                      ? Colors.black.withOpacity(0.75)
                      : Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                  color: isInWatchlist
                      ? const Color(0xFF4FC3F7) // لون أزرق فاتح مميز للـ watchlist
                      : Colors.white,
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
    final mediaType = movieDetail.runtime != null ? "movie" : "tv";

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