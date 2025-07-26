import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/view/cubit/split_screen/cubit_split_screen.dart';

import '../../view/cubit/split_screen/states_split_screen.dart';
import '../../view/data/genre_event.dart';

class GenreScreen extends StatelessWidget {
  const GenreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Your Favorite Movies")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<CubitSplitScreenBloc, StateSplitScreen>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Movie Genres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  const Text('TV Show Genres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
