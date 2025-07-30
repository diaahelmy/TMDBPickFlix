import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../view/cubit/search/search_cubit.dart';
import '../../../view/cubit/search/search_state.dart';
import '../../component/search/widgets/loading_more_indicator.dart';
import '../../component/search/widgets/search_bar_widget.dart';
import '../../component/search/widgets/search_body.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(
        movieRepository: context.read(),
      ),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false, // تم تغييره لحل مشكلة الـ overflow
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text(
          'Search Movies',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: kToolbarHeight, // ارتفاع ثابت للـ AppBar
      ),
      body: Column(
        children: [
          // شريط البحث في الأعلى
          const SearchBarWidget(),

          // باقي المحتوى
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Expanded(child: SearchBody(state: state)),
                    if (state is SearchSuccess && state.isLoadingMore)
                      const LoadingMoreIndicator(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}