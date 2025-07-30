import 'package:flutter/material.dart';
import '../../../../view/cubit/search/search_state.dart';
import '../../loading_grid_widget.dart';
import 'search_initial_widget.dart';
import 'search_success_widget.dart';
import 'search_empty_widget.dart';
import 'search_error_widget.dart';

class SearchBody extends StatelessWidget {
  final SearchState state;

  const SearchBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is SearchInitial) {
      return const SearchInitialWidget();
    } else if (state is SearchLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LoadingGridWidget(),
      );
    } else if (state is SearchSuccess) {
      return SearchSuccessWidget(state: state as SearchSuccess);
    } else if (state is SearchEmpty) {
      return SearchEmptyWidget(state: state as SearchEmpty);
    } else if (state is SearchError) {
      return SearchErrorWidget(state: state as SearchError);
    }

    return const SizedBox.shrink();
  }
}
