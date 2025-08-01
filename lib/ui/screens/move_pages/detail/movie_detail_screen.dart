import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/movie_detail_model.dart';
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
            if (state is MovieDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MovieDetailLoaded) {
              return _buildDetailView(context, state.movieDetail);
            } else if (state is MovieDetailError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, MovieDetail detail) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(detail.title, style: const TextStyle(fontSize: 16)),
            background: Image.network(
              'https://image.tmdb.org/t/p/w500${detail.posterPath}',
              fit: BoxFit.cover,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text("⭐ ${detail.voteAverage}")),
                    Chip(label: Text("📅 ${detail.releaseDate}")),
                    Chip(label: Text(source.toUpperCase())),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(detail.overview, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
