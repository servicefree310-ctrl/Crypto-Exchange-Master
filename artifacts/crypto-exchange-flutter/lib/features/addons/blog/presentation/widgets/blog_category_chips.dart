import 'package:flutter/material.dart';

class BlogCategoryChips extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const BlogCategoryChips({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Categories',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // All categories chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: selectedCategory == null,
                    label: Text(
                      'All',
                      style: TextStyle(
                        color: selectedCategory == null
                            ? Colors.white
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight: selectedCategory == null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    onSelected: (selected) => onCategorySelected(null),
                    selectedColor: theme.primaryColor,
                    backgroundColor:
                        theme.chipTheme.backgroundColor ?? theme.cardColor,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: selectedCategory == null
                            ? theme.primaryColor
                            : theme.dividerColor,
                        width: selectedCategory == null ? 2 : 1,
                      ),
                    ),
                  ),
                ),

                // Category chips
                ...categories.map((category) {
                  final isSelected = selectedCategory == category['slug'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category['name'] ?? '',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : theme.textTheme.bodyMedium?.color,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : theme.unselectedWidgetColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${category['postCount'] ?? 0}',
                              style: TextStyle(
                                color: isSelected
                                    ? theme.primaryColor
                                    : theme.textTheme.bodyMedium?.color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onSelected: (selected) => onCategorySelected(
                          selected ? category['slug'] : null),
                      selectedColor: theme.primaryColor,
                      backgroundColor:
                          theme.chipTheme.backgroundColor ?? theme.cardColor,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? theme.primaryColor
                              : theme.dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
