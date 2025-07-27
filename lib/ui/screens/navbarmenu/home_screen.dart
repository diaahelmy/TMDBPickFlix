import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../view/cubit/home/home_cubit.dart';
import '../../../view/cubit/home/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeUpcomingLoading) {
          return const CircularProgressIndicator();
        } else if (state is HomeUpcomingLoaded) {
          return ListView.builder(
            itemCount: state.movies.length,
            itemBuilder: (context, index) {
              return Text(state.movies[index].title);
            },
          );
        } else if (state is HomeUpcomingError) {
          return Text('Error: ${state.message}');
        }
        return const SizedBox();
      },
    );

  }
}
