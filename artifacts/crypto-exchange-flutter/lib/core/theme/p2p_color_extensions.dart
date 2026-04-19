import 'package:flutter/material.dart';
import 'global_theme_extensions.dart';

/// P2P-specific color extensions
/// These extend the global theme with P2P-specific color variants
extension P2PColorExtensions on BuildContext {
  /// Light variant of buy color for backgrounds
  Color get buyColorLight => buyColor.withValues(alpha: 0.1);
  
  /// Light variant of sell color for backgrounds  
  Color get sellColorLight => sellColor.withValues(alpha: 0.1);
  
  /// Dark variant of buy color
  Color get buyColorDark => buyColor;
  
  /// Dark variant of sell color
  Color get sellColorDark => sellColor;
}
