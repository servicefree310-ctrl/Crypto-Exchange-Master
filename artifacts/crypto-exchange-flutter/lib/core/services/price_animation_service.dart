import 'dart:async';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../theme/global_theme_extensions.dart';

@singleton
class PriceAnimationService {
  PriceAnimationService();

  // Price tracking for each symbol
  final Map<String, _PriceTracker> _priceTrackers = {};

  // Stream controllers for each symbol
  final Map<String, StreamController<Color>> _colorControllers = {};

  // Timer for color reset
  final Map<String, Timer> _resetTimers = {};

  /// Get color stream for a specific symbol
  Stream<Color> getColorStream(String symbol) {
    if (!_colorControllers.containsKey(symbol)) {
      _colorControllers[symbol] = StreamController<Color>.broadcast();
      _priceTrackers[symbol] = _PriceTracker();
    }
    return _colorControllers[symbol]!.stream;
  }

  /// Update price for a symbol and trigger color animation
  void updatePrice(String symbol, double newPrice, {BuildContext? context}) {
    final tracker = _priceTrackers[symbol];
    if (tracker == null) return;

    final previousPrice = tracker.currentPrice;
    tracker.updatePrice(newPrice);

    Color priceColor = Colors.white;

    if (previousPrice != null) {
      if (newPrice > previousPrice) {
        // Use theme green if context available, otherwise fallback to hardcoded
        priceColor = context?.priceUpColor ?? const Color(0xFF0ECE7A);
      } else if (newPrice < previousPrice) {
        // Use theme red if context available, otherwise fallback to hardcoded
        priceColor = context?.priceDownColor ?? const Color(0xFFFF5A5F);
      }
      // If equal, stays white
    }

    // Emit color change
    _colorControllers[symbol]?.add(priceColor);

    // Set up auto-reset timer if color changed
    if (priceColor != Colors.white) {
      _resetTimers[symbol]?.cancel();
      _resetTimers[symbol] = Timer(const Duration(seconds: 2), () {
        _colorControllers[symbol]?.add(Colors.white);
      });
    }
  }

  /// Update change percentage for a symbol and trigger color animation
  void updateChangePercentage(String symbol, double newChangePercent,
      {BuildContext? context}) {
    final tracker = _priceTrackers[symbol];
    if (tracker == null) return;

    final previousChangePercent = tracker.currentChangePercent;
    tracker.updateChangePercent(newChangePercent);

    Color changeColor = Colors.white;

    if (previousChangePercent != null) {
      if (newChangePercent > previousChangePercent) {
        // Use theme green if context available, otherwise fallback to hardcoded
        changeColor = context?.priceUpColor ?? const Color(0xFF0ECE7A);
      } else if (newChangePercent < previousChangePercent) {
        // Use theme red if context available, otherwise fallback to hardcoded
        changeColor = context?.priceDownColor ?? const Color(0xFFFF5A5F);
      }
      // If equal, stays white
    }

    // Emit color change for change percentage
    _colorControllers[symbol]?.add(changeColor);

    // Set up auto-reset timer if color changed
    if (changeColor != Colors.white) {
      _resetTimers[symbol]?.cancel();
      _resetTimers[symbol] = Timer(const Duration(seconds: 2), () {
        _colorControllers[symbol]?.add(Colors.white);
      });
    }
  }

  /// Get current color for a symbol with theme context
  Color getCurrentColor(String symbol, {BuildContext? context}) {
    final tracker = _priceTrackers[symbol];
    if (tracker == null) return Colors.white;

    // Check if there's an active timer (meaning color should be green/red)
    if (_resetTimers[symbol]?.isActive == true) {
      final previousPrice = tracker.previousPrice;
      final currentPrice = tracker.currentPrice;
      final previousChangePercent = tracker.previousChangePercent;
      final currentChangePercent = tracker.currentChangePercent;

      // Check price changes first
      if (previousPrice != null && currentPrice != null) {
        if (currentPrice > previousPrice) {
          return context?.priceUpColor ?? const Color(0xFF0ECE7A);
        } else if (currentPrice < previousPrice) {
          return context?.priceDownColor ?? const Color(0xFFFF5A5F);
        }
      }

      // Check change percentage changes
      if (previousChangePercent != null && currentChangePercent != null) {
        if (currentChangePercent > previousChangePercent) {
          return context?.priceUpColor ?? const Color(0xFF0ECE7A);
        } else if (currentChangePercent < previousChangePercent) {
          return context?.priceDownColor ?? const Color(0xFFFF5A5F);
        }
      }
    }

    return Colors.white;
  }

  /// Clear data for a symbol
  void clearSymbol(String symbol) {
    _resetTimers[symbol]?.cancel();
    _resetTimers.remove(symbol);
    _colorControllers[symbol]?.close();
    _colorControllers.remove(symbol);
    _priceTrackers.remove(symbol);
  }

  /// Clear all data
  void dispose() {
    for (final timer in _resetTimers.values) {
      timer.cancel();
    }
    for (final controller in _colorControllers.values) {
      controller.close();
    }
    _resetTimers.clear();
    _colorControllers.clear();
    _priceTrackers.clear();
  }
}

/// Helper class to track price and change percentage history for each symbol
class _PriceTracker {
  double? currentPrice;
  double? previousPrice;
  double? currentChangePercent;
  double? previousChangePercent;

  void updatePrice(double newPrice) {
    previousPrice = currentPrice;
    currentPrice = newPrice;
  }

  void updateChangePercent(double newChangePercent) {
    previousChangePercent = currentChangePercent;
    currentChangePercent = newChangePercent;
  }
}
