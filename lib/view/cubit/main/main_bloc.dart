import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/ui/screens/navbarmenu/home_screen.dart';
import 'package:pick_flix/ui/screens/navbarmenu/library_screen.dart';
import 'package:pick_flix/ui/screens/navbarmenu/search_screen.dart';
import 'package:pick_flix/view/cubit/main/main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainInitialState());

  static MainCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  final List<Widget> pages = [
    const HomeScreen(),
    const SearchScreen(),
    const LibraryScreen(),
  ];

  void changeBottomNav(int index) {
    if (currentIndex != index) {
      currentIndex = index;
      emit(MainChangeBottomNavState());
    }
  }

  List<BottomNavigationBarItem> bottomItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: "Home",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.search_outlined),
      activeIcon: Icon(Icons.search),
      label: "Search",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.library_books_outlined),
      activeIcon: Icon(Icons.library_books),
      label: "My Library",
    ),
  ];
}