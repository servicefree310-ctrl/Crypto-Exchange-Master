import 'package:equatable/equatable.dart';


/// P2P Payment Method Entity
///
/// Represents a payment method that can be used in P2P trades
/// Based on v5 backend payment method structure
class P2PPaymentMethodEntity extends Equatable {
  const P2PPaymentMethodEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.isEnabled,
    this.config,
    this.supportedCountries,
    this.limits,
  });

  /// Unique identifier
  final String id;

  /// Payment method name
  final String name;

  /// Payment method type
  final String type;

  /// Currency of the payment method
  final String currency;

  /// Whether the payment method is enabled
  final bool isEnabled;

  /// Configuration for the payment method
  final Map<String, dynamic>? config;

  /// Supported countries for the payment method
  final List<String>? supportedCountries;

  /// Limits for the payment method
  final Map<String, dynamic>? limits;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        currency,
        isEnabled,
        config,
        supportedCountries,
        limits,
      ];

  P2PPaymentMethodEntity copyWith({
    String? id,
    String? name,
    String? type,
    String? currency,
    bool? isEnabled,
    Map<String, dynamic>? config,
    List<String>? supportedCountries,
    Map<String, dynamic>? limits,
  }) {
    return P2PPaymentMethodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      isEnabled: isEnabled ?? this.isEnabled,
      config: config ?? this.config,
      supportedCountries: supportedCountries ?? this.supportedCountries,
      limits: limits ?? this.limits,
    );
  }

  factory P2PPaymentMethodEntity.fromJson(Map<String, dynamic> json) {
    return P2PPaymentMethodEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      currency: json['currency'] ?? '',
      isEnabled: json['isEnabled'] ?? false,
      config: json['config'],
      supportedCountries: json['supportedCountries']?.cast<String>(),
      limits: json['limits'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'currency': currency,
      'isEnabled': isEnabled,
      'config': config,
      'supportedCountries': supportedCountries,
      'limits': limits,
    };
  }

  bool get isInstantTransfer =>
      config?['processingTime']?.toLowerCase().contains('instant') == true;
  bool get hasFees =>
      config?['processingTime'] != null &&
      config?['processingTime']!.isNotEmpty &&
      config?['processingTime'] != '0' &&
      config?['processingTime'] != 'Free';

  String get displayFees => config?['processingTime'] ?? 'Free';
  String get displayProcessingTime => config?['processingTime'] ?? 'Unknown';
}
