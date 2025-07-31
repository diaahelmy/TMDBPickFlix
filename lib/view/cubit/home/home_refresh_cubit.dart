import 'package:flutter_bloc/flutter_bloc.dart';

abstract class HomeRefreshState {}

class HomeRefreshInitial extends HomeRefreshState {}
class HomeRefreshLoading extends HomeRefreshState {}
class HomeRefreshSuccess extends HomeRefreshState {}
class HomeRefreshError extends HomeRefreshState {
  final String message;
  HomeRefreshError(this.message);
}

class HomeRefreshCubit extends Cubit<HomeRefreshState> {
  final Future<void> Function() refreshCallback;

  HomeRefreshCubit(this.refreshCallback) : super(HomeRefreshInitial());

  Future<void> refresh() async {
    emit(HomeRefreshLoading());
    try {
      await refreshCallback();
      emit(HomeRefreshSuccess());
    } catch (e) {
      emit(HomeRefreshError(e.toString()));
    }
  }
}
