import 'package:flutter/material.dart';
import 'package:pick_flix/view/cubit/split_screen/cubit_split_screen.dart';
import 'package:pick_flix/view/cubit/split_screen/states_split_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../view/data/genre_event.dart';

class SplitsCreen extends StatelessWidget {
  const SplitsCreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CubitSplitScreenBloc, StateSplitScreen>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Movie Genres'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.movieGenres.map((genre) {
                return FilterChip(
                  label: Text(genre.name),
                  selected: genre.isSelected,
                  onSelected: (_) {
                    context.read<CubitSplitScreenBloc>().add(ToggleGenreSelection(genre.id));
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('TV Show Genres'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.tvGenres.map((genre) {
                return FilterChip(
                  label: Text(genre.name),
                  selected: genre.isSelected,
                  onSelected: (_) {
                    context.read<CubitSplitScreenBloc>().add(ToggleGenreSelection(genre.id));
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );

  }
}
