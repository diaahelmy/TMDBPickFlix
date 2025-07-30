import 'package:flutter/cupertino.dart';


import 'error_widget.dart';
import 'loading_grid_widget.dart';
import 'movie_grid.dart';

class _MovieListRow extends StatelessWidget {
  final List movies;

  const _MovieListRow({required this.movies});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: MovieGrid( movies: movies[index],),
          );
        },
      ),
    );
  }
}
class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 8,
        itemBuilder: (_, __) => const LoadingGridWidget(),
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRow({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ErrorWidgetCustom(
        message: message,
      ),
    );
  }
}

