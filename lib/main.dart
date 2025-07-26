import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/ui/screens/genre_screen.dart';
import 'package:pick_flix/ui/screens/movies_screen.dart';
import 'package:pick_flix/ui/screens/splits_creen.dart';
import 'package:pick_flix/view/api_service/ApiService.dart';
import 'package:pick_flix/view/api_service/repository/movie_repository.dart';
import 'package:pick_flix/view/cubit/movie/movie_bloc.dart';
import 'package:pick_flix/view/cubit/split_screen/cubit_split_screen.dart';
import 'package:pick_flix/view/data/genre_event.dart';
import 'package:pick_flix/view/themes/appthemes.dart';

void main() {

  final apiService = ApiService();
  final repository = MovieRepository(apiService);


  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final MovieRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [

        BlocProvider(create: (_) => MovieBloc(repository)),


        BlocProvider(create: (_) => CubitSplitScreenBloc()..add(LoadGenres())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PickFlix',
        theme: AppTheme.lightTheme,
        home: const GenreScreen(),
      ),
    );
  }
}
