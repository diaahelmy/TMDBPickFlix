import 'package:flutter/material.dart';
import 'grid_responsive_helper.dart';

abstract class BaseGrid<T> extends StatelessWidget {
  final List<T> items;
  final Set<T>? selectedItems;
  final ValueChanged<T>? onItemTap;
  final int? itemLimit;
  final int crossAxisCount;

  const BaseGrid({
    super.key,
    required this.items,
    this.selectedItems,
    this.onItemTap,
    this.itemLimit,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    final displayedItems = _getDisplayedItems();
    final screenWidth = MediaQuery.of(context).size.width;
    final dynamicCrossAxisCount = GridResponsiveHelper.calculateCrossAxisCount(
      screenWidth: screenWidth,
      defaultCount: crossAxisCount,
    );
    final aspectRatio = GridResponsiveHelper.calculateAspectRatio(screenWidth);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayedItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: dynamicCrossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, index) => buildGridItem(
        context,
        displayedItems[index],
        selectedItems?.contains(displayedItems[index]) ?? false,
        index,
      ),
    );
  }

  List<T> _getDisplayedItems() {
    return itemLimit != null
        ? items.take(itemLimit!).toList()
        : items;
  }

  Widget buildGridItem(BuildContext context, T item, bool isSelected, int index);
}