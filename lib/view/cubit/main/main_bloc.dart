import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/ui/screens/navbarmenu/home_screen.dart';
import 'package:pick_flix/ui/screens/navbarmenu/library_screen.dart';
import 'package:pick_flix/ui/screens/navbarmenu/search_screen.dart';
import 'package:pick_flix/view/cubit/main/main_state.dart';

class MainCubit extends Cubit<MainState>{

  MainCubit():super(MainInitialState());
  static MainCubit get(context) => BlocProvider.of(context);
  int currentIndex=0  ;
  final List<Widget>page=[
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),

  ];
  void changeBottomNav(int index) {
    currentIndex = index;
    emit(MainChangeBottomNavState());
  }

  List<BottomNavigationBarItem> bottomItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
    BottomNavigationBarItem(
        icon: Icon(Icons.library_books), label: "Library"),
  ];
}