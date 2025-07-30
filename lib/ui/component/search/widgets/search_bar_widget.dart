import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/ui/component/search/widgets/search_history_helper.dart';
import 'package:pick_flix/view/cubit/search/search_cubit.dart';
import '../../../../view/cubit/search/search_state.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  List<String> _searchHistory = [];
  bool _showHistory = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await SearchHistoryHelper.getSearchHistory();
    if (mounted) {
      setState(() {
        _searchHistory = history;
      });
    }
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;

    if (hasText) {
      // إخفاء التاريخ فورًا عند الكتابة
      _hideHistory();
      // البحث مع التأخير
      context.read<SearchCubit>().searchMovies(_controller.text);
    } else if (!hasText) {
      // إذا النص فارغ، امسح البحث وأرجع للحالة الأولية
      context.read<SearchCubit>().clearSearch();
      // إذا الحقل مركز عليه وفيه تاريخ، اعرض التاريخ
      if (_focusNode.hasFocus && _searchHistory.isNotEmpty) {
        _showHistoryOverlay();
      }
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      // عند التركيز على الحقل
      if (_controller.text.isEmpty && _searchHistory.isNotEmpty) {
        _showHistoryOverlay();
      }
    } else {
      // عند فقدان التركيز
      _hideHistory();
    }
  }

  void _showHistoryOverlay() {
    if (_overlayEntry != null) return;

    setState(() {
      _showHistory = true;
    });

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideHistory() {
    setState(() {
      _showHistory = false;
    });
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + 16, // نفس padding الـ search bar
        top: offset.dy + size.height - 4, // أقرب للـ search bar
        width: size.width - 32, // نفس عرض الـ search bar
        child: Material(
          elevation: 4,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: _buildHistoryContainer(),
        ),
      ),
    );
  }

  void _selectHistoryItem(String term) {
    // إخفاء التاريخ أولاً
    _hideHistory();

    // كتابة النص
    _controller.text = term;

    // إزالة التركيز من الحقل
    _focusNode.unfocus();

    // البحث فورًا بدون تأخير
    context.read<SearchCubit>().searchMoviesImmediate(term);

    // تحديث موضع العنصر في التاريخ (بشكل غير متزامن)
    Future.microtask(() => SearchHistoryHelper.updateTermPosition(term));
  }

  Future<void> _removeHistoryItem(String term) async {
    await SearchHistoryHelper.removeTerm(term);
    await _loadHistory();

    // إذا لم يعد هناك تاريخ، اخفي الـ overlay
    if (_searchHistory.isEmpty) {
      _hideHistory();
    } else {
      // تحديث الـ overlay
      _removeOverlay();
      if (_showHistory) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry!);
      }
    }
  }

  Future<void> _clearAllHistory() async {
    await SearchHistoryHelper.clearHistory();
    await _loadHistory();
    _hideHistory();
  }

  Widget _buildHistoryContainer() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _buildHeader(theme, colorScheme),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _buildHistoryList(theme, colorScheme),
            ),
          ),
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

  Widget _buildHistoryList(ThemeData theme, ColorScheme colorScheme) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric( vertical: 16),
      itemCount: _searchHistory.length,
      itemBuilder: (context, index) {
        final term = _searchHistory[index];
        return InkWell(
          onTap: () => _selectHistoryItem(term),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 18,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    term,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                InkWell(
                  onTap: () => _removeHistoryItem(term),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SearchCubit, SearchState>(
      listener: (context, state) {
        // إضافة إلى التاريخ عند نجاح البحث
        if (state is SearchSuccess && state.query.isNotEmpty) {
          Future.microtask(() async {
            await SearchHistoryHelper.addSearchTerm(state.query);
            if (mounted) {
              _loadHistory();
            }
          });
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search movies...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _controller.clear();
                  _hideHistory();
                  context.read<SearchCubit>().clearSearch();
                  // إعادة إظهار التاريخ إذا كان الحقل مركز عليه
                  if (_focusNode.hasFocus && _searchHistory.isNotEmpty) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (_focusNode.hasFocus && _controller.text.isEmpty) {
                        _showHistoryOverlay();
                      }
                    });
                  }
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: _showHistory
                    ? const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                )
                    : BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
          ),
        ),
      ),
    );
  }
}