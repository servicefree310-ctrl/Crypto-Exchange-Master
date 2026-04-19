import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';

class NewsSearchBar extends StatefulWidget {
  const NewsSearchBar({
    super.key,
    required this.onSearch,
  });

  final Function(String) onSearch;

  @override
  State<NewsSearchBar> createState() => _NewsSearchBarState();
}

class _NewsSearchBarState extends State<NewsSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Clear search if empty
    if (value.trim().isEmpty) {
      widget.onSearch('');
      return;
    }

    // Only search if query is at least 2 characters
    if (value.trim().length < 2) {
      return;
    }

    // Debounce search - wait 500ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: context.borderColor,
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: context.bodyS.copyWith(
          color: context.textPrimary,
          fontSize: 13.0,
        ),
        decoration: InputDecoration(
          hintText: 'Search crypto news...',
          hintStyle: context.bodyS.copyWith(
            color: context.textSecondary,
            fontSize: 13.0,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: context.textSecondary,
            size: 18.0,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    _debounceTimer?.cancel();
                    widget.onSearch('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: context.textSecondary,
                    size: 16.0,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.isSmallScreen ? 8.0 : 12.0,
            vertical: context.isSmallScreen ? 8.0 : 10.0,
          ),
        ),
        onChanged: _onSearchChanged,
        onSubmitted: (value) {
          _debounceTimer?.cancel();
          if (value.trim().isNotEmpty) {
            widget.onSearch(value.trim());
          }
        },
      ),
    );
  }
}
