import 'package:equatable/equatable.dart';

class KycLevelEntity extends Equatable {
  final String id;
  final String? serviceId;
  final String name;
  final String? description;
  final int level;
  final List<KycFieldEntity>? fields;
  final List<String>? features;
  final String status; // ACTIVE, DRAFT, INACTIVE
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const KycLevelEntity({
    required this.id,
    this.serviceId,
    required this.name,
    this.description,
    required this.level,
    this.fields,
    this.features,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        serviceId,
        name,
        description,
        level,
        fields,
        features,
        status,
        createdAt,
        updatedAt,
      ];

  KycLevelEntity copyWith({
    String? id,
    String? serviceId,
    String? name,
    String? description,
    int? level,
    List<KycFieldEntity>? fields,
    List<String>? features,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KycLevelEntity(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      fields: fields ?? this.fields,
      features: features ?? this.features,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class KycFieldEntity extends Equatable {
  final String id;
  final int? order;
  final KycFieldType type;
  final String label;
  final String? description;
  final String? placeholder;
  final bool? required;
  final List<KycFieldOptionEntity>? options;
  final List<KycFieldEntity>? fields;
  final KycFieldValidationEntity? validation;
  final KycFieldConditionalEntity? conditional;
  final int? rows;
  final int? min;
  final int? step;
  final String? format;
  final String? accept;
  final int? maxSize;
  final bool? multiple;
  final KycVerificationFieldEntity? verificationField;
  final List<KycIdentityTypeEntity>? identityTypes;
  final String? defaultType;
  final bool? requireSelfie;
  final bool? hidden;

  const KycFieldEntity({
    required this.id,
    this.order,
    required this.type,
    required this.label,
    this.description,
    this.placeholder,
    this.required,
    this.options,
    this.fields,
    this.validation,
    this.conditional,
    this.rows,
    this.min,
    this.step,
    this.format,
    this.accept,
    this.maxSize,
    this.multiple,
    this.verificationField,
    this.identityTypes,
    this.defaultType,
    this.requireSelfie,
    this.hidden,
  });

  @override
  List<Object?> get props => [
        id,
        order,
        type,
        label,
        description,
        placeholder,
        required,
        options,
        fields,
        validation,
        conditional,
        rows,
        min,
        step,
        format,
        accept,
        maxSize,
        multiple,
        verificationField,
        identityTypes,
        defaultType,
        requireSelfie,
        hidden,
      ];
}

enum KycFieldType {
  text,
  email,
  password,
  number,
  tel,
  url,
  date,
  datetime,
  time,
  select,
  multiSelect,
  radio,
  checkbox,
  textarea,
  file,
  image,
  address,
  identity,
  phone,
  section,
}

class KycFieldOptionEntity extends Equatable {
  final String value;
  final String label;

  const KycFieldOptionEntity({
    required this.value,
    required this.label,
  });

  @override
  List<Object?> get props => [value, label];
}

class KycFieldValidationEntity extends Equatable {
  final int? minLength;
  final int? maxLength;
  final String? pattern;
  final String? message;
  final int? min;
  final int? max;

  const KycFieldValidationEntity({
    this.minLength,
    this.maxLength,
    this.pattern,
    this.message,
    this.min,
    this.max,
  });

  @override
  List<Object?> get props => [minLength, maxLength, pattern, message, min, max];
}

class KycFieldConditionalEntity extends Equatable {
  final String field;
  final String operator;
  final dynamic value;

  const KycFieldConditionalEntity({
    required this.field,
    required this.operator,
    required this.value,
  });

  @override
  List<Object?> get props => [field, operator, value];
}

class KycVerificationFieldEntity extends Equatable {
  final String serviceFieldId;
  final String mappingType;

  const KycVerificationFieldEntity({
    required this.serviceFieldId,
    required this.mappingType,
  });

  @override
  List<Object?> get props => [serviceFieldId, mappingType];
}

class KycIdentityTypeEntity extends Equatable {
  final String value;
  final String label;
  final List<KycFieldEntity> fields;

  const KycIdentityTypeEntity({
    required this.value,
    required this.label,
    required this.fields,
  });

  @override
  List<Object?> get props => [value, label, fields];
}
