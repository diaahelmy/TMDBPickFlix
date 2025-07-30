import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../view/cubit/search/search_cubit.dart';
import '../../../../view/cubit/search/search_state.dart';
import '../../no_internet/no_internet_widget.dart'; // تأكد من المسار الصحيح

class SearchErrorWidget extends StatelessWidget {
  final SearchError state;

  const SearchErrorWidget({super.key, required this.state});


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: NoInternetWidget(
              onRetry: () {
                context.read<SearchCubit>().retrySearch();
              },
            ),
          ),
        ),
      ),
    );
  }
}
