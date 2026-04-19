import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import 'package:flutter/services.dart';

/// P2P App Bar with search and filters
/// Follows KuCoin compact design and v5 functionality
class P2PAppBar extends StatefulWidget implements PreferredSizeWidget {
  const P2PAppBar({
    super.key,
    required this.title,
    this.showSearch = false,
    this.showFilters = false,
    this.onSearchChanged,
    this.onFiltersPressed,
    this.searchHint = 'Search...',
    this.actions,
    this.leading,
    this.backgroundColor,
    this.elevation = 0,
  });

  final String title;
  final bool showSearch;
  final bool showFilters;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFiltersPressed;
  final String searchHint;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final double elevation;

  @override
  State<P2PAppBar> createState() => _P2PAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _P2PAppBarState extends State<P2PAppBar>
    with SingleTickerProviderStateMixin {
  bool _isSearchMode = false;
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _searchAnimation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (_isSearchMode) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _searchController.clear();
        widget.onSearchChanged?.call('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: widget.backgroundColor ??
          (context.colors.surface),
      elevation: widget.elevation,
      leading: widget.leading,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isSearchMode && widget.showSearch
            ? _buildSearchField()
            : Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
      actions: _buildActions(context, isDark),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? context.cardBackground
            : context.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? context.borderColor
              : context.borderColor,
        ),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: widget.searchHint,
          hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? context.textTertiary
                : context.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: Theme.of(context).brightness == Brightness.dark
                ? context.textSecondary
                : context.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        onChanged: widget.onSearchChanged,
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, bool isDark) {
    final actions = <Widget>[];

    // Search button
    if (widget.showSearch) {
      actions.add(
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isSearchMode ? Icons.close : Icons.search,
              key: ValueKey(_isSearchMode),
              color: isDark
                  ? context.textSecondary
                  : context.textSecondary,
            ),
          ),
          onPressed: _toggleSearch,
          tooltip: _isSearchMode ? 'Close search' : 'Search',
        ),
      );
    }

    // Filters button
    if (widget.showFilters) {
      actions.add(
        IconButton(
          icon: Icon(
            Icons.tune,
            color: isDark
                ? context.textSecondary
                : context.textSecondary,
          ),
          onPressed: widget.onFiltersPressed,
          tooltip: 'Filters',
        ),
      );
    }

    // Custom actions
    if (widget.actions != null) {
      actions.addAll(widget.actions!);
    }

    return actions;
  }
}

/// Compact P2P Tab Bar for navigation
class P2PTabBar extends StatelessWidget implements PreferredSizeWidget {
  const P2PTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
  });

  final List<Widget> tabs;
  final TabController? controller;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(
            color: context.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs,
        isScrollable: isScrollable,
        indicatorColor: context.colors.primary,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: context.colors.primary,
        unselectedLabelColor:
            context.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
