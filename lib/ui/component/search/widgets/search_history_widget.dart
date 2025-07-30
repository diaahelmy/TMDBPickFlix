import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/ui/component/search/widgets/search_history_helper.dart';
import 'package:pick_flix/view/cubit/search/search_cubit.dart';
import 'package:pick_flix/view/cubit/search/search_state.dart';

class SearchHistoryWidget extends StatefulWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;

  const SearchHistoryWidget({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
  });

  @override
  State<SearchHistoryWidget> createState() => _SearchHistoryWidgetState();
}

class _SearchHistoryWidgetState extends State<SearchHistoryWidget> {
  List<String> _searchHistory = [];
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    widget.searchController.addListener(_onTextChanged);
    widget.searchFocusNode.addListener(_onFocusChanged);

    // Add some test data if no history exists (for testing)
    _addTestHistoryIfEmpty();
  }

  Future<void> _addTestHistoryIfEmpty() async {
    final history = await SearchHistoryHelper.getSearchHistory();
    if (history.isEmpty) {
      // Add some sample searches for testing
      await SearchHistoryHelper.addSearchTerm('Spider-Man');
      await SearchHistoryHelper.addSearchTerm('Batman');
      await SearchHistoryHelper.addSearchTerm('Avengers');
      _loadHistory();
    }
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onTextChanged);
    widget.searchFocusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.searchController.text.isNotEmpty;

    // Hide history immediately when user starts typing
    if (hasText && _showHistory) {
      setState(() {
        _showHistory = false;
      });
    } else if (!hasText && widget.searchFocusNode.hasFocus && _searchHistory.isNotEmpty) {
      setState(() {
        _showHistory = true;
      });
    }
  }

  void _onFocusChanged() {
    print('Focus changed: ${widget.searchFocusNode.hasFocus}, Text: "${widget.searchController.text}", History: $_searchHistory'); // Debug
    setState(() {
      _showHistory = widget.searchFocusNode.hasFocus &&
          widget.searchController.text.isEmpty &&
          _searchHistory.isNotEmpty;
    });
    print('Show history: $_showHistory'); // Debug
  }

  Future<void> _loadHistory() async {
    final history = await SearchHistoryHelper.getSearchHistory();
    print('Loaded history: $history'); // Debug print
    if (mounted) {
      setState(() {
        _searchHistory = history;
        // Show history if field is focused, empty, and we have history
        final shouldShow = widget.searchFocusNode.hasFocus &&
            widget.searchController.text.isEmpty &&
            _searchHistory.isNotEmpty;
        _showHistory = shouldShow;
        print('Should show history: $shouldShow'); // Debug print
      });
    }
  }

  void _selectHistoryItem(String term) {
    // Hide history immediately
    setState(() {
      _showHistory = false;
    });

    // Set the text and trigger search immediately
    widget.searchController.text = term;
    widget.searchFocusNode.unfocus();

    // Trigger immediate search without debounce
    context.read<SearchCubit>().searchMoviesImmediate(term);

    // Update history position (non-blocking)
    SearchHistoryHelper.updateTermPosition(term);
  }

  Future<void> _removeHistoryItem(String term) async {
    await SearchHistoryHelper.removeTerm(term);
    _loadHistory();
  }

  Future<void> _clearAllHistory() async {
    await SearchHistoryHelper.clearHistory();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    print('Building widget - Show history: $_showHistory, History count: ${_searchHistory.length}'); // Debug
    return BlocListener<SearchCubit, SearchState>(
      listener: (context, state) {
        // Add to history when search is successful
        if (state is SearchSuccess && state.query.isNotEmpty) {
          print('Adding to history: ${state.query}'); // Debug
          // Use microtask to avoid blocking UI
          Future.microtask(() async {
            await SearchHistoryHelper.addSearchTerm(state.query);
            if (mounted) {
              _loadHistory();
            }
          });
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _showHistory ? _buildHistoryContainer() : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildHistoryContainer() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: const ValueKey('history'),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme, colorScheme),
          const SizedBox(height: 12),
          _buildHistoryChips(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          Icons.history_rounded,
          size: 18,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 6),
        Text(
          'Recent Searches',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: _clearAllHistory,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Clear All',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryChips(ThemeData theme, ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _searchHistory.map((term) {
            return _buildHistoryChip(term, theme, colorScheme, constraints.maxWidth);
          }).toList(),
        );
      },
    );
  }

  Widget _buildHistoryChip(String term, ThemeData theme, ColorScheme colorScheme, double maxWidth) {
    // Calculate max width for each chip to prevent overflow
    const double chipPadding = 32; // padding + icon + spacing
    const double spacing = 6;
    const double minChipWidth = 60;

    // Estimate how many chips can fit in one row
    final double availableWidth = maxWidth - chipPadding;
    final double maxChipWidth = (availableWidth / 2) - spacing; // Minimum 2 chips per row

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxChipWidth.clamp(minChipWidth, availableWidth),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectHistoryItem(term),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    term,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _removeHistoryItem(term),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}