import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/ui/screens/genre_screen.dart';
import 'package:pick_flix/view/cubit/split_screen/cubit_split_screen.dart';
import 'package:pick_flix/view/data/genre_event.dart';
import 'package:pick_flix/view/themes/appthemes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitSplitScreenBloc()..add(LoadGenres()), // تحميل التصنيفات
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Genre Selector',
        theme: AppTheme.lightTheme,
        home: const GenreScreen(),
      ),
    );
  }
}
