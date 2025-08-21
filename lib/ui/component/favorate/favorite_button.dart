import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/movie_model.dart';
import '../../../models/movie_detail_model.dart';
import '../../../models/search_result.dart';
import '../../../view/cubit/favorites/favorites_cubit.dart';
import '../../../view/cubit/favorites/favorites_state.dart';

class FavoriteButton extends StatelessWidget {
  final Movie? movie;
  final MovieDetail? movieDetail;

  const FavoriteButton({super.key, this.movie, this.movieDetail})
    : assert(
        movie != null || movieDetail != null,
        'Either movie or movieDetail must be provided',
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final favoritesCubit = context.read<FavoritesCubit>();

        // الحصول على الـ id والعنوان
        final movieId = movie?.id ?? movieDetail!.id;
        final movieTitle = movie?.title ?? movieDetail!.title;

        final isFavorite = favoritesCubit.cachedFavorites.any(
          (m) => m.id == movieId,
        );

        // تحويل MovieDetail إلى Movie إذا لزم الأمر
        final movieToSave = movie ?? _movieDetailToMovie(movieDetail!);

        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
              size: 22,
            ),
            onPressed: () async {
              final wasAlreadyFavorite = isFavorite;
         // أو MediaType.tv.name إذا المسلسل
              final mediaType =
                  MediaType.movie.name;
              // استدعاء toggleFavorite مع النوع الصحيح
              await favoritesCubit.toggleFavoriteDynamic(
                isFavorite: !wasAlreadyFavorite, movie: movieToSave,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      wasAlreadyFavorite
                          ? 'Removed from favorites'
                          : 'Added to favorites',
                    ),
                    backgroundColor: const Color(0xFFFF6B35),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  /// تحويل MovieDetail إلى Movie
  Movie _movieDetailToMovie(MovieDetail movieDetail) {
    final mediaType =
        MediaType.movie.name;
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
