import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/view/cubit/split_screen/cubit_split_screen.dart';

import '../../view/cubit/split_screen/states_split_screen.dart';
import '../../view/data/genre_event.dart';
import '../component/bottom_button_widget.dart';
import '../component/navigation_helper.dart';
import '../component/selection_status_widget.dart';
import 'movies_screen.dart';

class GenreScreen extends StatelessWidget {
  const GenreScreen({super.key});
  int _calculateSelectedCount(StateSplitScreen state) {
    final selectedIds = <int>{};
    selectedIds.addAll(
        state.movieGenres.where((g) => g.isSelected).map((g) => g.id));
    selectedIds.addAll(
        state.tvGenres.where((g) => g.isSelected).map((g) => g.id));
    return selectedIds.length;
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Select Your Favorite Movies")),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<CubitSplitScreenBloc, StateSplitScreen>(
          builder: (context, state) {

            final selectedCount = _calculateSelectedCount(state);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SelectionStatusWidget(
                    selectedCount: selectedCount,
                    minimumSelection: 3,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Movie Genres',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.tvGenres.map((genre) {
                      final theme = Theme.of(context);
                      final isSelected = genre.isSelected;

                      return ChoiceChip(
                        selected: isSelected,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            if (isSelected) ...[
                              Icon(
                                Icons.check,
                                size: 18,
                              color: isSelected ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface ,),

                              const SizedBox(width: 6),
                            ],


                            Text(
                              genre.name,
                              style: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        selectedColor: theme.colorScheme.secondary,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (_) {
                          context
                              .read<CubitSplitScreenBloc>()
                              .add(ToggleGenreSelection(genre.id));
                        },
                      );
                    }).toList(),
                  )



                  ,

                  const SizedBox(height: 20),
                  const Text(
                    'TV Show Genres',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.movieGenres.map((genre) {
                      final theme = Theme.of(context);
                      final isSelected = genre.isSelected;

                      return ChoiceChip(
                        selected: isSelected,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            if (isSelected) ...[
                              Icon(
                                Icons.check,
                                size: 18,
                                color: isSelected ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface ,  ),
                              const SizedBox(width: 6),
                            ],

                            // النص بعد علامة الصح
                            Text(
                              genre.name,
                              style: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        selectedColor: theme.colorScheme.secondary,
                        backgroundColor:  theme.colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (_) {
                          context
                              .read<CubitSplitScreenBloc>()
                              .add(ToggleGenreSelection(genre.id));
                        },
                      );
                    }).toList(),
                  )

                  ,
                ],
              ),
            );
          },
        ),
      ),

      // ✅ البوتوم بوتن الجديد
      bottomNavigationBar: BlocBuilder<CubitSplitScreenBloc, StateSplitScreen>(
        builder: (context, state) {
          final selectedCount = _calculateSelectedCount(state);
          return BottomButtonWidget(



          isEnabled: selectedCount >= 3,
            selectedCount: selectedCount,
            minimumSelection: 3,
            onContinue: () {
              navigateAndFinish(
                context,
                const FavoritesSelectionScreen(),
              );
            },
          );
        },
      ),
    );

  }
}

