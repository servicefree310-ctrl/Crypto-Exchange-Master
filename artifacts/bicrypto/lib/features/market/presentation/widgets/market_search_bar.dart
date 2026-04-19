import 'package:flutter/material.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';

class MarketSearchBar extends StatefulWidget {
  const MarketSearchBar({
    super.key,
    this.onChanged,
    this.controller,
    this.hintText = 'Search',
    this.enabled = true,
    this.isCompact = true,
  });

  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String hintText;
  final bool enabled;
  final bool isCompact;

  @override
  State<MarketSearchBar> createState() => _MarketSearchBarState();
}

class _MarketSearchBarState extends State<MarketSearchBar> {
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.isCompact ? 0 : 4),
      height: widget.isCompact ? 42 : 48,
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(widget.isCompact ? 12 : 14),
        border: Border.all(
          color: _isFocused
              ? context.colors.primary.withValues(alpha: 0.5)
              : context.dividerColor,
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Focus(
        onFocusChange: (focused) {
          setState(() {
            _isFocused = focused;
          });
        },
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          style: context.labelM.copyWith(
            color: context.textPrimary,
            fontSize: widget.isCompact ? 14 : 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: context.labelM.copyWith(
              color: context.textSecondary,
              fontSize: widget.isCompact ? 14 : 16,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.2,
            ),
            prefixIcon: Container(
              width: widget.isCompact ? 42 : 48,
              height: widget.isCompact ? 42 : 48,
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.search_rounded,
                  color: _isFocused
                      ? context.colors.primary
                      : context.textSecondary,
                  size: widget.isCompact ? 20 : 22,
                ),
              ),
            ),
            suffixIcon: _hasText
                ? Container(
                    width: widget.isCompact ? 42 : 48,
                    height: widget.isCompact ? 42 : 48,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        widget.controller?.clear();
                        widget.onChanged?.call('');
                      },
                      child: Container(
                        width: widget.isCompact ? 20 : 24,
                        height: widget.isCompact ? 20 : 24,
                        decoration: BoxDecoration(
                          color: context.dividerColor,
                          borderRadius:
                              BorderRadius.circular(widget.isCompact ? 10 : 12),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: context.textPrimary,
                          size: widget.isCompact ? 14 : 16,
                        ),
                      ),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.isCompact ? 14 : 16,
              vertical: widget.isCompact ? 12 : 14,
            ),
          ),
        ),
      ),
    );
  }
}
