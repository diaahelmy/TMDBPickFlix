import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import '../../view/cubit/main/main_bloc.dart';
import '../../view/cubit/main/main_state.dart';


class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainState>(
      bloc: MainCubit.get(context), // أو BlocProvider.of<MainCubit>(context)
      listener: (context, state) {

        if (state is MainErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
      },
      builder: (context, state) {
        var cubit = MainCubit.get(context);

        return Scaffold(
          body: cubit.page[cubit.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: cubit.currentIndex,
            onTap: (index) => cubit.changeBottomNav(index),
            items:cubit.bottomItems,
          ),
        );
      },
    );
  }
}
