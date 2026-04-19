import 'package:flutter/material.dart';

import '../theme/global_theme_extensions.dart';

/// Simple full-screen widget that informs the user that there is no
/// internet connection available.
///
/// Shown when the app failed to reach the backend during start-up.
class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // You can replace this with a proper asset icon if available
                Icon(Icons.wifi_off, size: 96, color: context.colors.primary),
                const SizedBox(height: 32),
                Text(
                  'No internet connection',
                  style: context.h2.copyWith(color: context.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Please check your network settings and try again.',
                  style: context.bodyM.copyWith(color: context.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
