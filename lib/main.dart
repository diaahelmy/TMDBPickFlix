import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pick_flix/ui/screens/genre_screen.dart';
import 'package:pick_flix/ui/screens/login-out/login_screen.dart';
import 'package:pick_flix/ui/screens/main_screen.dart';
import 'package:pick_flix/ui/screens/movies_screen.dart';
import 'package:pick_flix/ui/screens/navbarmenu/home_screen.dart';
import 'package:pick_flix/view/api_service/ApiService.dart';
import 'package:pick_flix/view/api_service/repository/movie_repository.dart';
import 'package:pick_flix/view/cubit/favorites/favorites_cubit.dart';
import 'package:pick_flix/view/cubit/home/home_cubit.dart';
import 'package:pick_flix/view/cubit/home/home_movies_recommendation/home_movies_recommendation_cubit.dart';
import 'package:pick_flix/view/cubit/home/top_rate/home_toprated_cubit.dart';
import 'package:pick_flix/view/cubit/home/upcoming/home_upcoming_cubit.dart';
import 'package:pick_flix/view/cubit/home/popular/popular_movies_cubit.dart';
import 'package:pick_flix/view/cubit/main/main_bloc.dart';
import 'package:pick_flix/view/cubit/movie/movie_bloc.dart';
import 'package:pick_flix/view/cubit/search/search_cubit.dart';
import 'package:pick_flix/view/cubit/split_screen/cubit_split_screen.dart';
import 'package:pick_flix/view/cubit/tab_change/TabState.dart';
import 'package:pick_flix/view/data/genre_event.dart';
import 'package:pick_flix/view/data/movie_event.dart';
import 'package:pick_flix/view/helper/SelectedPreferencesHelper.dart';
import 'package:pick_flix/view/helper/cache.dart';
import 'package:pick_flix/view/themes/appthemes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Cache.init();
  final prefs = await SharedPreferences.getInstance();
  final sessionId = prefs.getString('session_id');
  final accountId = prefs.getInt('account_id');

  final selectedGenres = SelectedPreferencesHelper.getSelectedGenres();
  final selectedMovies = SelectedPreferencesHelper.getSelectedItems();
  final savedSessionId = prefs.getString('session_id');
  Widget initialScreen;


  if (savedSessionId != null && savedSessionId.isNotEmpty) {
    // عندنا session محفوظ → نروح عـ Home
    initialScreen = const MainScreen();
  } else {
    // لو مفيش Session → نمشي بالخطوات القديمة
    if (selectedGenres.isEmpty) {
      initialScreen = const GenreScreen();
    } else if (selectedMovies.isEmpty) {
      initialScreen =  FavoritesSelectionScreen();
    } else {
      initialScreen = LoginScreen();
    }
  }


  runApp(
    RepositoryProvider<MovieRepository>(
      create: (_) => MovieRepository(ApiService()),
      child: MyApp(initialScreen: initialScreen, selectedItems: selectedMovies,    sessionId: sessionId,
        accountId: accountId,),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  final List<SelectedMovieWithSource> selectedItems;
  final String? sessionId;
  final int? accountId;
  const MyApp({
    super.key,
    this.sessionId,
    this.accountId,
    required this.initialScreen,
    required this.selectedItems,
  });

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
            BlocProvider(create: (_) => MainCubit()),
            BlocProvider(create: (context) => HomeCubit()),
            BlocProvider(
              create: (context) =>
                  HomeMoviesRecommendationCubit(repository)
                    ..fetchRecommendations(selectedItems),
            ),
            BlocProvider(
              create: (context) => FavoritesCubit(
                repository,
                accountId ?? 0,
                sessionId ?? '',
              ),
            ),


            // BlocProvider(
            //   create: (context) => HomeGenreRecommendationCubit(repository),
            // ),
            BlocProvider(
              create: (context) => TabCubit(),
            ),
            BlocProvider(
              create: (context) =>
                  HomePopularCubit(repository)..fetchPopularMovies(
                  ContentType.movie,),
            ),
            BlocProvider(
              create: (context) =>
                  HomeUpcomingCubit(repository)..fetchUpcomingMovies(
                    ContentType.movie,
                  ),
            ),
            BlocProvider(
              create: (context) =>
                  HomeTopRatedCubit(repository)..fetchTopRatedMovies(
                      ContentType.movie
                  ),
            ),

            BlocProvider(
              create: (context) =>
                  SearchCubit(movieRepository: repository)..searchMovies(''),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PickFlix',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: initialScreen,
          ),
        );
      },
    );
  }
}
