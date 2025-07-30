import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../view/cubit/search/search_cubit.dart';
import '../../../../view/cubit/search/search_state.dart';
import '../../no_internet/no_internet_widget.dart'; // تأكد من المسار الصحيح

class SearchErrorWidget extends StatelessWidget {
  final SearchError state;

  const SearchErrorWidget({super.key, required this.state});

  String _getErrorMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('failed host lookup')) {
      return 'No internet connection. Please check your network.';
    } else if (lower.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NoInternetWidget(
        subtitle: _getErrorMessage(state.message),
        onRetry: () {
          context.read<SearchCubit>().retrySearch();
        },
      ),
    );
  }
}
