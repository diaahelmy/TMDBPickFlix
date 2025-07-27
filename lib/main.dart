import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pick_flix/ui/screens/genre_screen.dart';
import 'package:pick_flix/view/api_service/ApiService.dart';
import 'package:pick_flix/view/api_service/repository/movie_repository.dart';
import 'package:pick_flix/view/cubit/home/home_cubit.dart';
import 'package:pick_flix/view/cubit/main/main_bloc.dart';
import 'package:pick_flix/view/cubit/movie/movie_bloc.dart';
import 'package:pick_flix/view/cubit/split_screen/cubit_split_screen.dart';
import 'package:pick_flix/view/data/genre_event.dart';
import 'package:pick_flix/view/data/movie_event.dart';
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
    return ScreenUtilInit( //  أضف ScreenUtilInit
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => MovieBloc(repository)
                ..add(FetchTopRatedMovies())
                ..add(FetchTopRatedTv()),
            ),
            BlocProvider(
              create: (_) => CubitSplitScreenBloc()..add(LoadGenres()),
            ),
            BlocProvider(
              create: (_) => MainCubit(),
            ),
            BlocProvider(
              create: (context) => HomeCubit(repository)..fetchHomeUpComingMovies(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PickFlix',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const GenreScreen(),
          ),
        );
      },
    );
  }
}
