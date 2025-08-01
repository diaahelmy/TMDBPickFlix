import 'package:flutter/material.dart';
import '../../../../models/movie_model.dart';
import 'movie_grid_card.dart';
import 'base_grid.dart';

class MovieGrid extends BaseGrid<Movie> {
  final bool showDetails;
  final bool showDescription;

  const MovieGrid({
    super.key,
    required super.items,
    super.selectedItems,
    super.onItemTap,
    super.itemLimit,
    super.crossAxisCount = 3,
    this.showDetails = false,
    this.showDescription = false,
  });

  @override
  Widget buildGridItem(BuildContext context, Movie movie, bool isSelected, int index) {
    return MovieGridCard(
      movie: movie,
      isSelected: isSelected,
      showDetails: showDetails,
      showDescription: showDescription,
      onTap: onItemTap,
    );
  }
}