import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pick_flix/ui/screens/genre_screen.dart';
import 'package:pick_flix/ui/screens/main_screen.dart';
import 'package:pick_flix/ui/screens/movies_screen.dart';
import 'package:pick_flix/ui/screens/navbarmenu/home_screen.dart';
import 'package:pick_flix/ui/screens/navbarmenu/search_screen.dart';
import 'package:pick_flix/view/api_service/ApiService.dart';
import 'package:pick_flix/view/api_service/repository/movie_repository.dart';
import 'package:pick_flix/view/cubit/home/home_cubit.dart';
import 'package:pick_flix/view/cubit/main/main_bloc.dart';
import 'package:pick_flix/view/cubit/movie/movie_bloc.dart';
import 'package:pick_flix/view/cubit/search/search_cubit.dart';
import 'package:pick_flix/view/cubit/split_screen/cubit_split_screen.dart';
import 'package:pick_flix/view/data/genre_event.dart';
import 'package:pick_flix/view/data/movie_event.dart';
import 'package:pick_flix/view/helper/SelectedPreferencesHelper.dart';
import 'package:pick_flix/view/helper/cache.dart';
import 'package:pick_flix/view/themes/appthemes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Cache.init(); // تأكد من تهيئة SharedPreferences

  final selectedGenres = await SelectedPreferencesHelper.getSelectedGenres();
  final selectedMovies = await SelectedPreferencesHelper.getSelectedMovies();

  Widget initialScreen;

  if (selectedGenres.isEmpty) {
    initialScreen = const GenreScreen();
  } else if (selectedMovies.isEmpty) {
    initialScreen = const FavoritesSelectionScreen();
  } else {
    initialScreen = const MainScreen();
  }

  runApp(
    RepositoryProvider<MovieRepository>(
      create: (_) => MovieRepository(ApiService()),
      child: MyApp(initialScreen: initialScreen, selectedMovieIds: selectedMovies,),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  final List<int> selectedMovieIds;
  const MyApp({super.key,required this.initialScreen,required this.selectedMovieIds});

  @override
  Widget build(BuildContext context) {
    final repository = RepositoryProvider.of<MovieRepository>(context);

    return ScreenUtilInit(
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
              create: (context) => HomeCubit(repository)
                ..fetchHomeUpComingMovies()
                ..fetchHomePopularMovies()
                ..fetchHomeTopRatedMovies()
              ..fetchRecommendationsBySelectedMovies(selectedMovieIds),
            ),
            BlocProvider(
              create: (context) => SearchCubit(movieRepository: repository)
                ..searchMovies(''),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PickFlix',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home:  initialScreen,
          ),
        );
      },
    );
  }
}
