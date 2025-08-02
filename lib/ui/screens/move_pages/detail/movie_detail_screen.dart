import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../models/movie_detail_model.dart';
import '../../../../models/video_result.dart';
import '../../../../view/cubit/detail/movie_detail_cubit.dart';
import '../../../../view/cubit/detail/movie_detail_state.dart';

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
              MovieDetailError(:final message) => _ErrorView(message: message),
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

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
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
              _buildStatsSection(context, theme),
              _buildProductionSection(context, theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    final firstTrailer = movieDetail.allTrailers.isNotEmpty
        ? movieDetail.allTrailers.first
        : null;

    final backdropUrl = movieDetail.backdropPath != null
        ? 'https://image.tmdb.org/t/p/w1280${movieDetail.backdropPath}'
        : 'https://image.tmdb.org/t/p/w500${movieDetail.posterPath}';

    return SliverAppBar(
      pinned: true,
      expandedHeight: 250,
      flexibleSpace: FlexibleSpaceBar(
        background: firstTrailer != null
            ? GestureDetector(
          onTap: () => _playTrailer(context, firstTrailer),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                firstTrailer.youtubeThumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: const Icon(Icons.play_circle_fill, size: 60, color: Colors.white),
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ],
          ),
        )
            : Image.network(
          backdropUrl,
          fit: BoxFit.cover,
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

  Widget _buildProductionSection(BuildContext context, ThemeData theme) {
    if (movieDetail.productionCompanies.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Production Companies',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: movieDetail.productionCompanies.length,
              itemBuilder: (context, index) {
                final company = movieDetail.productionCompanies[index];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (company.logoPath != null) ...[
                            Expanded(
                              child: Image.network(
                                'https://image.tmdb.org/t/p/w200${company.logoPath}',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.business),
                              ),
                            ),
                          ] else ...[
                            const Icon(Icons.business),
                            const SizedBox(height: 4),
                            Text(
                              company.name,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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

  Widget _buildTrailerSection(BuildContext context, ThemeData theme) {
    final mainTrailer = movieDetail.mainTrailer;
    if (mainTrailer == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    mainTrailer.youtubeThumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: const Icon(Icons.play_circle, size: 64),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _playTrailer(context, mainTrailer),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 72,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainTrailer.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(mainTrailer.type),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (mainTrailer.official)
                        Chip(
                          label: const Text('Official'),
                          backgroundColor: Colors.green.withOpacity(0.2),
                          labelStyle: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allTrailers.length,
              itemBuilder: (context, index) {
                final video = allTrailers[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _playTrailer(context, video),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  video.youtubeThumbnail,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: theme.colorScheme.surfaceVariant,
                                        child: const Icon(Icons.play_circle),
                                      ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.name,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  video.type,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  void _playTrailer(BuildContext context, Video video) {
    showDialog(
      context: context,
      builder: (context) => _VideoPlayerDialog(video: video),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}

class _VideoPlayerDialog extends StatefulWidget {
  final Video video;

  const _VideoPlayerDialog({required this.video});

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.key,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        captionLanguage: 'en',
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              widget.video.name,
              style: const TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () async {
                  final url = Uri.parse(widget.video.youtubeUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            progressColors: const ProgressBarColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Chip(
                  label: Text(widget.video.type),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                if (widget.video.official)
                  Chip(
                    label: const Text('Official'),
                    backgroundColor: Colors.green.withOpacity(0.3),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}