import 'package:equatable/equatable.dart';

import '../entities/chart_entity.dart';

/// Value object for trade display formatting
class TradeDisplayVO extends Equatable {
  const TradeDisplayVO({
    required this.trade,
  });

  final TradeDataPoint trade;

  /// Formatted price based on price range
  String get formattedPrice {
    final price = trade.price;
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(4);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(6);
    } else {
      return price.toStringAsFixed(8);
    }
  }

  /// Formatted amount with smart abbreviations
  String get formattedAmount {
    final amount = trade.amount;
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else if (amount >= 1) {
      return amount.toStringAsFixed(3);
    } else {
      return amount.toStringAsFixed(6);
    }
  }

  /// Formatted time with relative display
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(trade.timestamp);

    if (diff.inMinutes < 1) {
      return 'now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else {
      return '${trade.timestamp.hour.toString().padLeft(2, '0')}:${trade.timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Trade side indicator
  bool get isBuy => trade.isBuy;

  /// Trade color based on side
  int get tradeColorValue => isBuy ? 0xFF00D4AA : 0xFFFF4757;

  /// Background color with opacity
  int get backgroundColorValue => isBuy ? 0x1400D4AA : 0x14FF4757;

  @override
  List<Object> get props => [trade];
}
