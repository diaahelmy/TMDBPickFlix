import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/movie_model.dart';
import '../../view/cubit/movie/movie_bloc.dart';
import '../../view/cubit/movie/movie_state.dart';
import '../../view/data/movie_event.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  @override
  void initState() {
    super.initState();
    final movieBloc = context.read<MovieBloc>();
    movieBloc.add(FetchPopularMovies());
    movieBloc.add(FetchTopRatedMovies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Popular & Top Rated")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(title: "Popular Movies"),
            BlocBuilder<MovieBloc, MovieState>(
              builder: (context, state) {
                if (state is MovieCombinedState) {
                  if (state.popularMovies != null) {
                    return _buildGrid(state.popularMovies!);
                  } else if (state.isLoading) {
                    return const CircularProgressIndicator();
                  } else if (state.error != null) {
                    return Text("Error: ${state.error}");
                  }
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            const _SectionTitle(title: "Top Rated Movies"),
            BlocBuilder<MovieBloc, MovieState>(
              builder: (context, state) {
                if (state is MovieCombinedState) {
                  if (state.topRatedMovies != null) {
                    return _buildGrid(state.topRatedMovies!);
                  } else if (state.isLoading) {
                    return const CircularProgressIndicator();
                  } else if (state.error != null) {
                    return Text("Error: ${state.error}");
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Movie> movies) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: movies.length > 12 ? 12 : movies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2 / 3,
      ),
      itemBuilder: (context, index) {
        final movie = movies[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
