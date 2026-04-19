import 'package:equatable/equatable.dart';

// Alias for backward compatibility and clarity
typedef ShippingEntity = ShippingMethodEntity;
typedef ShippingAddressEntity = AddressEntity;

class ShippingMethodEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double cost;
  final String currency;
  final bool isDefault;
  final int estimatedDays;
  final bool status;

  const ShippingMethodEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.currency,
    required this.isDefault,
    required this.estimatedDays,
    required this.status,
  });

  @override
  List<Object> get props => [
        id,
        name,
        description,
        cost,
        currency,
        isDefault,
        estimatedDays,
        status,
      ];

  ShippingMethodEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? cost,
    String? currency,
    bool? isDefault,
    int? estimatedDays,
    bool? status,
  }) {
    return ShippingMethodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      isDefault: isDefault ?? this.isDefault,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      status: status ?? this.status,
    );
  }
}

class AddressEntity extends Equatable {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String company;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phone;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.company,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phone,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        firstName,
        lastName,
        company,
        address1,
        address2,
        city,
        state,
        postalCode,
        country,
        phone,
        isDefault,
      ];

  AddressEntity copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? company,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phone,
    bool? isDefault,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      company: company ?? this.company,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get fullName => '$firstName $lastName';

  String get fullAddress {
    final parts = [
      address1,
      if (address2.isNotEmpty) address2,
      city,
      state,
      postalCode,
      country,
    ];
    return parts.join(', ');
  }
}
