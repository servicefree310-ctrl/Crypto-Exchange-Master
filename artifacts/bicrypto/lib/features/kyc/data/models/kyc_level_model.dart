import 'dart:convert';
import 'dart:developer' as dev;

import '../../domain/entities/kyc_level_entity.dart';

class KycLevelModel extends KycLevelEntity {
  const KycLevelModel({
    required super.id,
    super.serviceId,
    required super.name,
    super.description,
    required super.level,
    super.fields,
    super.features,
    required super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory KycLevelModel.fromJson(Map<String, dynamic> json) {
    // Handle potential null or empty fields array
    List<KycFieldModel>? parsedFields;
    if (json['fields'] != null) {
      if (json['fields'] is String) {
        // Parse JSON string
        try {
          final fieldsJson = json['fields'] as String;
          if (fieldsJson.trim().isNotEmpty) {
            final decoded = jsonDecode(fieldsJson);
            if (decoded is List) {
              parsedFields = (decoded)
                  .map((field) => KycFieldModel.fromJson(field))
                  .toList();
            }
          }
        } catch (e) {
          dev.log('Error parsing fields JSON string: $e');
          parsedFields = null;
        }
      } else if (json['fields'] is List) {
        // Already a list
        parsedFields = (json['fields'] as List)
            .map((field) => KycFieldModel.fromJson(field))
            .toList();
      }
    }

    // Handle features array
    List<String>? parsedFeatures;
    if (json['features'] != null) {
      if (json['features'] is String) {
        try {
          final featuresJson = json['features'] as String;
          if (featuresJson.trim().isNotEmpty) {
            final decoded = jsonDecode(featuresJson);
            if (decoded is List) {
              parsedFeatures = (decoded).cast<String>();
            }
          }
        } catch (e) {
          dev.log('Error parsing features JSON string: $e');
          parsedFeatures = null;
        }
      } else if (json['features'] is List) {
        parsedFeatures = (json['features'] as List).cast<String>();
      }
    }

    return KycLevelModel(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      level: json['level'] as int,
      fields: parsedFields,
      features: parsedFeatures,
      status: json['status'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'name': name,
      'description': description,
      'level': level,
      'fields': fields?.map((f) => (f as KycFieldModel).toJson()).toList(),
      'features': features,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class KycFieldModel extends KycFieldEntity {
  const KycFieldModel({
    required super.id,
    super.order,
    required super.type,
    required super.label,
    super.description,
    super.placeholder,
    super.required,
    super.options,
    super.fields,
    super.validation,
    super.conditional,
    super.rows,
    super.min,
    super.step,
    super.format,
    super.accept,
    super.maxSize,
    super.multiple,
    super.verificationField,
    super.identityTypes,
    super.defaultType,
    super.requireSelfie,
    super.hidden,
  });

  factory KycFieldModel.fromJson(Map<String, dynamic> json) {
    return KycFieldModel(
      id: json['id'] as String,
      order: json['order'] as int?,
      type: _parseFieldType(json['type']),
      label: json['label'] as String,
      description: json['description'] as String?,
      placeholder: json['placeholder'] as String?,
      required: json['required'] as bool?,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((option) => KycFieldOptionModel.fromJson(option))
              .toList()
          : null,
      fields: json['fields'] != null
          ? (json['fields'] as List)
              .map((field) => KycFieldModel.fromJson(field))
              .toList()
          : null,
      validation: json['validation'] != null
          ? KycFieldValidationModel.fromJson(json['validation'])
          : null,
      conditional: json['conditional'] != null
          ? KycFieldConditionalModel.fromJson(json['conditional'])
          : null,
      rows: json['rows'] as int?,
      min: json['min'] as int?,
      step: json['step'] as int?,
      format: json['format'] as String?,
      accept: json['accept'] as String?,
      maxSize: json['maxSize'] as int?,
      multiple: json['multiple'] as bool?,
      verificationField: json['verificationField'] != null
          ? KycVerificationFieldModel.fromJson(json['verificationField'])
          : null,
      identityTypes: json['identityTypes'] != null
          ? (json['identityTypes'] as List)
              .map((type) => KycIdentityTypeModel.fromJson(type))
              .toList()
          : null,
      defaultType: json['defaultType'] as String?,
      requireSelfie: json['requireSelfie'] as bool?,
      hidden: json['hidden'] as bool?,
    );
  }

  static KycFieldType _parseFieldType(dynamic type) {
    if (type is String) {
      switch (type.toUpperCase()) {
        case 'TEXT':
          return KycFieldType.text;
        case 'EMAIL':
          return KycFieldType.email;
        case 'PASSWORD':
          return KycFieldType.password;
        case 'NUMBER':
          return KycFieldType.number;
        case 'TEL':
          return KycFieldType.tel;
        case 'URL':
          return KycFieldType.url;
        case 'DATE':
          return KycFieldType.date;
        case 'DATETIME':
          return KycFieldType.datetime;
        case 'TIME':
          return KycFieldType.time;
        case 'SELECT':
          return KycFieldType.select;
        case 'MULTISELECT':
          return KycFieldType.multiSelect;
        case 'RADIO':
          return KycFieldType.radio;
        case 'CHECKBOX':
          return KycFieldType.checkbox;
        case 'TEXTAREA':
          return KycFieldType.textarea;
        case 'FILE':
          return KycFieldType.file;
        case 'IMAGE':
          return KycFieldType.image;
        case 'ADDRESS':
          return KycFieldType.address;
        case 'IDENTITY':
          return KycFieldType.identity;
        case 'PHONE':
          return KycFieldType.phone;
        case 'SECTION':
          return KycFieldType.section;
        default:
          return KycFieldType.text;
      }
    }
    return KycFieldType.text;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'type': type.name.toUpperCase(),
      'label': label,
      'description': description,
      'placeholder': placeholder,
      'required': required,
      'options':
          options?.map((o) => (o as KycFieldOptionModel).toJson()).toList(),
      'fields': fields?.map((f) => (f as KycFieldModel).toJson()).toList(),
      'validation': (validation as KycFieldValidationModel?)?.toJson(),
      'conditional': (conditional as KycFieldConditionalModel?)?.toJson(),
      'rows': rows,
      'min': min,
      'step': step,
      'format': format,
      'accept': accept,
      'maxSize': maxSize,
      'multiple': multiple,
      'verificationField':
          (verificationField as KycVerificationFieldModel?)?.toJson(),
      'identityTypes': identityTypes
          ?.map((t) => (t as KycIdentityTypeModel).toJson())
          .toList(),
      'defaultType': defaultType,
      'requireSelfie': requireSelfie,
      'hidden': hidden,
    };
  }
}

class KycFieldOptionModel extends KycFieldOptionEntity {
  const KycFieldOptionModel({
    required super.value,
    required super.label,
  });

  factory KycFieldOptionModel.fromJson(Map<String, dynamic> json) {
    return KycFieldOptionModel(
      value: json['value'] as String,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }
}

class KycFieldValidationModel extends KycFieldValidationEntity {
  const KycFieldValidationModel({
    super.minLength,
    super.maxLength,
    super.pattern,
    super.message,
    super.min,
    super.max,
  });

  factory KycFieldValidationModel.fromJson(Map<String, dynamic> json) {
    return KycFieldValidationModel(
      minLength: json['minLength'] as int?,
      maxLength: json['maxLength'] as int?,
      pattern: json['pattern'] as String?,
      message: json['message'] as String?,
      min: json['min'] as int?,
      max: json['max'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minLength': minLength,
      'maxLength': maxLength,
      'pattern': pattern,
      'message': message,
      'min': min,
      'max': max,
    };
  }
}

class KycFieldConditionalModel extends KycFieldConditionalEntity {
  const KycFieldConditionalModel({
    required super.field,
    required super.operator,
    required super.value,
  });

  factory KycFieldConditionalModel.fromJson(Map<String, dynamic> json) {
    return KycFieldConditionalModel(
      field: json['field'] as String,
      operator: json['operator'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'operator': operator,
      'value': value,
    };
  }
}

class KycVerificationFieldModel extends KycVerificationFieldEntity {
  const KycVerificationFieldModel({
    required super.serviceFieldId,
    required super.mappingType,
  });

  factory KycVerificationFieldModel.fromJson(Map<String, dynamic> json) {
    return KycVerificationFieldModel(
      serviceFieldId: json['serviceFieldId'] as String,
      mappingType: json['mappingType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceFieldId': serviceFieldId,
      'mappingType': mappingType,
    };
  }
}

class KycIdentityTypeModel extends KycIdentityTypeEntity {
  const KycIdentityTypeModel({
    required super.value,
    required super.label,
    required super.fields,
  });

  factory KycIdentityTypeModel.fromJson(Map<String, dynamic> json) {
    return KycIdentityTypeModel(
      value: json['value'] as String,
      label: json['label'] as String,
      fields: (json['fields'] as List)
          .map((field) => KycFieldModel.fromJson(field))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
      'fields': fields.map((f) => (f as KycFieldModel).toJson()).toList(),
    };
  }
}
