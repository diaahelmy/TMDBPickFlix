abstract class MainState{}

class MainInitialState extends MainState {}

class MainChangeBottomNavState extends MainState {}

class MainErrorState extends MainState {
  final String errorMessage;
  MainErrorState(this.errorMessage);
}