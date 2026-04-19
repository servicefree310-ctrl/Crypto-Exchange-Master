import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../bloc/shop/shop_bloc.dart';

class ShopSearchBar extends StatefulWidget {
  const ShopSearchBar({super.key});

  @override
  State<ShopSearchBar> createState() => _ShopSearchBarState();
}

class _ShopSearchBarState extends State<ShopSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      context.read<ShopBloc>().add(ShopSearchChanged(query: query));
    }
  }

  void _clearSearch() {
    _controller.clear();
    context.read<ShopBloc>().add(const ShopSearchChanged(query: ''));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.search,
            color: context.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              style: context.bodyM,
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: context.bodyM.copyWith(
                  color: context.textTertiary,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: _onSearchSubmitted,
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: context.textSecondary,
                size: 20,
              ),
              onPressed: _clearSearch,
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
