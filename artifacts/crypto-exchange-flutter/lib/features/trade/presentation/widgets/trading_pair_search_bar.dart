import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';

class TradingPairSearchBar extends StatelessWidget {
  const TradingPairSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search',
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.inputBackground,
            context.theme.scaffoldBackgroundColor,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: context.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      controller.clear();
                      onChanged?.call('');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.clear,
                        color: context.textTertiary,
                        size: 16,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.tune,
                      color: context.textTertiary,
                      size: 16,
                    ),
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ),
    );
  }
}
