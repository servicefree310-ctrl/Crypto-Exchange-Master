import '../../domain/entities/shipping_entity.dart';

class ShippingMethodModel extends ShippingMethodEntity {
  const ShippingMethodModel({
    required super.id,
    required super.name,
    required super.description,
    required super.cost,
    required super.currency,
    required super.isDefault,
    required super.estimatedDays,
    required super.status,
  });

  factory ShippingMethodModel.fromJson(Map<String, dynamic> json) {
    return ShippingMethodModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      isDefault: json['isDefault'] == true,
      estimatedDays: (json['estimatedDays'] as num?)?.toInt() ?? 0,
      status: json['status'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cost': cost,
      'currency': currency,
      'isDefault': isDefault,
      'estimatedDays': estimatedDays,
      'status': status,
    };
  }

  ShippingMethodEntity toEntity() => this;
}

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.userId,
    required super.firstName,
    required super.lastName,
    required super.company,
    required super.address1,
    required super.address2,
    required super.city,
    required super.state,
    required super.postalCode,
    required super.country,
    required super.phone,
    super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      address1: json['address1']?.toString() ?? '',
      address2: json['address2']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'company': company,
      'address1': address1,
      'address2': address2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
      'isDefault': isDefault,
    };
  }

  AddressEntity toEntity() => this;
}
