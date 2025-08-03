import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/movie_detail_model.dart';
import '../../../../models/video_result.dart';
import '../../../../view/cubit/detail/movie_detail_cubit.dart';
import '../../../../view/cubit/detail/movie_detail_state.dart';
import '../../../component/no_internet/no_internet_widget.dart';
import '../../../component/video_player/video_player_dialog.dart';

class MovieDetailScreen extends StatelessWidget {
  final int id;
  final String source;

  const MovieDetailScreen({
    super.key,
    required this.id,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MovieDetailCubit(context)..fetchDetail(id, source: source),
      child: Scaffold(
        body: BlocBuilder<MovieDetailCubit, MovieDetailState>(
          builder: (context, state) {
            return switch (state) {
              MovieDetailLoading() => const _LoadingView(),
              MovieDetailLoaded(:final movieDetail) =>
                  _DetailView(movieDetail: movieDetail, source: source),
              MovieDetailError() => Center(child: NoInternetWidget(onRetry: () => context.read<MovieDetailCubit>().fetchDetail(id, source: source))),
              MovieDetailInitial() => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading movie details...'),
          ],
        ),
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  final MovieDetail movieDetail;
  final String source;

  const _DetailView({
    required this.movieDetail,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, theme),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildHeroSection(context, theme),
              _buildInfoSection(context, theme),
              _buildOverviewSection(context, theme),
              _buildGenresSection(context, theme),
              _buildVideosSection(context, theme),
              _buildStatsSection(context, theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 300,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: isDark ? Colors.white : Colors.white,

      // Custom leading button
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),

      // Custom actions
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added to favorites'),
                  backgroundColor: const Color(0xFFFF6B35),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              _shareMovie(context);
            },
            icon: const Icon(
              Icons.share,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: _buildImageSlider(context),
      ),
    );
  }

  Widget _buildImageSlider(BuildContext context) {
    // جمع جميع الصور المتاحة
    final List<String> images = _getMovieImages();

    return Container(
      height: 300,
      child: Stack(
        children: [
          // Image Slider
          PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(images[index]),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {
                      // Fallback to gradient background
                    },
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              );
            },
            onPageChanged: (index) {
              // يمكنك إضافة منطق هنا للتحكم في الصفحة الحالية
            },
          ),

          // Page indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),

          // Play button overlay للتريلر (إذا كان متوفر)
          if (movieDetail.allTrailers.isNotEmpty)
            Positioned.fill(
              child: Center(
                child: GestureDetector(
                  onTap: () => _playTrailer(context, movieDetail.allTrailers.first),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.6),
                      border: Border.all(
                        color: const Color(0xFFFF6B35),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),

          // Movie title overlay
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movieDetail.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (movieDetail.tagline?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    movieDetail.tagline!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

// دالة لجمع صور الفيلم
  List<String> _getMovieImages() {
    List<String> images = [];

    // إضافة backdrop image
    if (movieDetail.backdropPath != null) {
      images.add('https://image.tmdb.org/t/p/w1280${movieDetail.backdropPath}');
    }

    // إضافة poster image
    if (movieDetail.posterPath != null) {
      images.add('https://image.tmdb.org/t/p/w500${movieDetail.posterPath}');
    }

    // إضافة صور التريلر
    for (var trailer in movieDetail.allTrailers.take(3)) {
      images.add(trailer.youtubeThumbnail);
    }

    // إضافة صور الإنتاج (إذا كانت متوفرة)
    for (var company in movieDetail.productionCompanies.take(2)) {
      if (company.logoPath != null) {
        images.add('https://image.tmdb.org/t/p/w200${company.logoPath}');
      }
    }

    // إذا لم تكن هناك صور، أضف صورة افتراضية
    if (images.isEmpty) {
      images.add('https://via.placeholder.com/1280x720/1976D2/FFFFFF?text=Movie');
    }

    return images;
  }

// Add share functionality
  void _shareMovie(BuildContext context) {
    // You can implement actual sharing logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${movieDetail.title}'),
        backgroundColor: const Color(0xFF1976D2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  Widget _buildHeroSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPosterCard(theme),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movieDetail.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (movieDetail.tagline?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    movieDetail.tagline!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _buildQuickInfo(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterCard(ThemeData theme) {
    return Card(
      elevation: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 120,
          height: 180,
          child: Image.network(
            'https://image.tmdb.org/t/p/w500${movieDetail.posterPath}',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: theme.colorScheme.surfaceVariant,
              child: const Icon(Icons.movie, size: 32),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfo(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildInfoChip(
          icon: Icons.star,
          label: movieDetail.formattedVoteAverage,
          color: Colors.amber,
          theme: theme,
        ),
        _buildInfoChip(
          icon: Icons.calendar_today,
          label: movieDetail.releaseDate.split('-').first,
          color: Colors.blue,
          theme: theme,
        ),
        if (movieDetail.runtime != null)
          _buildInfoChip(
            icon: Icons.access_time,
            label: movieDetail.formattedRuntime,
            color: Colors.green,
            theme: theme,
          ),
        _buildInfoChip(
          icon: Icons.source,
          label: source.toUpperCase(),
          color: Colors.purple,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInfoRow('Status', movieDetail.status, theme),
              _buildInfoRow('Language', movieDetail.spokenLanguages.isNotEmpty
                  ? movieDetail.spokenLanguages.first.englishName : 'N/A', theme),
              _buildInfoRow('Budget', movieDetail.formattedBudget, theme),
              _buildInfoRow('Revenue', movieDetail.formattedRevenue, theme),
              _buildInfoRow('Popularity', movieDetail.popularity.toStringAsFixed(1), theme),
              if (movieDetail.homepage?.isNotEmpty == true)
                _buildLinkRow('Homepage', movieDetail.homepage!, theme),
              if (movieDetail.imdbId?.isNotEmpty == true)
                _buildLinkRow('IMDb', 'https://imdb.com/title/${movieDetail.imdbId}', theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          )),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }

  Widget _buildLinkRow(String label, String url, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          )),
          GestureDetector(
            onTap: () => _launchUrl(url),
            child: Text(
              'Open',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context, ThemeData theme) {
    if (movieDetail.overview.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            movieDetail.overview,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenresSection(BuildContext context, ThemeData theme) {
    if (movieDetail.genres.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Genres',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: movieDetail.genres.map((genre) => Chip(
              label: Text(genre.name),
              backgroundColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Rating', movieDetail.formattedVoteAverage, theme),
              _buildStatColumn('Votes', '${movieDetail.voteCount}', theme),
              if (movieDetail.runtime != null)
                _buildStatColumn('Runtime', movieDetail.formattedRuntime, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }


  Widget _buildVideosSection(BuildContext context, ThemeData theme) {
    final allTrailers = movieDetail.allTrailers;
    if (allTrailers.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Videos & Trailers',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allTrailers.length,
              itemBuilder: (context, index) {
                final video = allTrailers[index];
                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _playTrailer(context, video),
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // صورة الفيديو
                          Expanded(
                            flex: 3,
                            child: Container(
                              width: double.infinity,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    video.youtubeThumbnail,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          color: theme.colorScheme.surfaceVariant,
                                          child: const Icon(
                                            Icons.play_circle,
                                            size: 40,
                                          ),
                                        ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.center,
                                        end: Alignment.center,
                                        colors: [
                                          Colors.black.withOpacity(0.1),
                                          Colors.black.withOpacity(0.3),
                                        ],
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.play_circle_fill,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                  ),
                                  // مدة الفيديو
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        video.type == 'Trailer' ? 'Trailer' : 'Video',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // معلومات الفيديو
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    video.name,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          video.type,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      if (video.official)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Official',
                                            style: TextStyle(
                                              color: Colors.green[600],
                                              fontSize: 9,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  void _playTrailer(BuildContext context, Video video) {
    showDialog(
      context: context,
      builder: (context) => VideoPlayerDialog(video: video),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}

