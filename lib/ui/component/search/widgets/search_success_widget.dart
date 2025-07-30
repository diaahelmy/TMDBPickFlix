import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../view/cubit/search/search_cubit.dart';
import '../../../../view/cubit/search/search_state.dart';
import '../../movie_grid.dart';

class SearchSuccessWidget extends StatefulWidget {
  final SearchSuccess state;

  const SearchSuccessWidget({super.key, required this.state});

  @override
  State<SearchSuccessWidget> createState() => _SuccessStateState();
}

class _SuccessStateState extends State<SearchSuccessWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SearchCubit>().loadMoreResults();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Found ${widget.state.movies.length} results for "${widget.state.query}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MovieGrid(
                movies: widget.state.movies,
                showDetails: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}