import 'package:flutter/material.dart';

class BlogSearchBar extends StatefulWidget {
  final Function(String)? onSearch;
  final Function(String)? onChanged;
  final String? hintText;

  const BlogSearchBar({
    super.key,
    this.onSearch,
    this.onChanged,
    this.hintText,
  });

  @override
  State<BlogSearchBar> createState() => _BlogSearchBarState();
}

class _BlogSearchBarState extends State<BlogSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search articles...',
          hintStyle: theme.inputDecorationTheme.hintStyle ??
              theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.iconTheme.color?.withValues(alpha: 0.6),
            size: 20,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch?.call('');
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.clear,
                    color: theme.iconTheme.color?.withValues(alpha: 0.6),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: theme.textTheme.bodyMedium,
        onChanged: (value) {
          setState(() {});
          widget.onChanged?.call(value);
        },
        onSubmitted: (value) {
          widget.onSearch?.call(value);
        },
      ),
    );
  }
}
