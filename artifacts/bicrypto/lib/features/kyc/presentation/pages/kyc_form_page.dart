import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as core;
import '../../domain/entities/kyc_level_entity.dart';
import '../../domain/entities/kyc_application_entity.dart';
import '../bloc/kyc_bloc.dart';
import '../bloc/kyc_event.dart';
import '../bloc/kyc_state.dart';

final sl = GetIt.instance;

class KycFormPage extends StatelessWidget {
  final String levelId;
  final KycApplicationEntity? existingApplication;

  const KycFormPage({
    super.key,
    required this.levelId,
    this.existingApplication,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<KycBloc>()..add(KycLevelByIdLoadRequested(levelId: levelId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            existingApplication != null
                ? 'Update KYC Application'
                : 'KYC Application',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _KycFormBody(existingApplication: existingApplication),
      ),
    );
  }
}

class _KycFormBody extends StatelessWidget {
  final KycApplicationEntity? existingApplication;

  const _KycFormBody({this.existingApplication});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KycBloc, KycState>(
      listener: (context, state) {
        if (state is KycApplicationSubmitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is KycApplicationUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is KycError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is KycLoading) {
          return LoadingWidget(message: state.message);
        }

        if (state is KycError) {
          return core.ErrorWidget(
            message: state.message,
            onRetry: () {
              // Re-fetch the level
            },
          );
        }

        if (state is KycLevelLoaded) {
          return _KycDynamicForm(
            level: state.level,
            existingApplication: existingApplication,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _KycDynamicForm extends StatefulWidget {
  final KycLevelEntity level;
  final KycApplicationEntity? existingApplication;

  const _KycDynamicForm({
    required this.level,
    this.existingApplication,
  });

  @override
  State<_KycDynamicForm> createState() => _KycDynamicFormState();
}

class _KycDynamicFormState extends State<_KycDynamicForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _fieldValues = {};
  final Map<String, String> _uploadedFiles = {};
  final Map<String, bool> _uploadingFields = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate from existing application if updating
    if (widget.existingApplication != null) {
      _fieldValues.addAll(widget.existingApplication!.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.level.fields ?? [];
    final visibleFields =
        fields.where((f) => f.hidden != true && f.type != KycFieldType.section);

    return BlocListener<KycBloc, KycState>(
      listener: (context, state) {
        if (state is KycDocumentUploadedState) {
          setState(() {
            _uploadedFiles[state.fieldId] = state.fileUrl;
            _fieldValues[state.fieldId] = state.fileUrl;
            _uploadingFields[state.fieldId] = false;
          });
        } else if (state is KycDocumentUploadError) {
          setState(() {
            _uploadingFields[state.fieldId] = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is KycDocumentUploading) {
          setState(() {
            _uploadingFields[state.fieldId] = true;
          });
        } else if (state is KycLoading) {
          setState(() {
            _isSubmitting = true;
          });
        } else if (state is KycApplicationSubmitSuccess ||
            state is KycApplicationUpdateSuccess) {
          setState(() {
            _isSubmitting = false;
          });
        } else if (state is KycError) {
          setState(() {
            _isSubmitting = false;
          });
        }
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Level info header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Theme.of(context)
                          .primaryColor
                          .withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.level.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.level.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.level.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Render each field section
              ...fields.map((field) {
                if (field.hidden == true) return const SizedBox.shrink();

                if (field.type == KycFieldType.section) {
                  return _buildSectionHeader(field);
                }

                return _buildFieldWidget(field);
              }),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.existingApplication != null
                              ? 'Update Application'
                              : 'Submit Application',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(KycFieldEntity field) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Text(
            field.label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (field.description != null) ...[
            const SizedBox(height: 4),
            Text(
              field.description!,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldWidget(KycFieldEntity field) {
    // Check conditional visibility
    if (field.conditional != null) {
      final condField = field.conditional!.field;
      final condValue = _fieldValues[condField];
      final expectedValue = field.conditional!.value;

      switch (field.conditional!.operator) {
        case 'equals':
        case '==':
          if (condValue?.toString() != expectedValue?.toString()) {
            return const SizedBox.shrink();
          }
          break;
        case 'notEquals':
        case '!=':
          if (condValue?.toString() == expectedValue?.toString()) {
            return const SizedBox.shrink();
          }
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildField(field),
    );
  }

  Widget _buildField(KycFieldEntity field) {
    switch (field.type) {
      case KycFieldType.text:
      case KycFieldType.email:
      case KycFieldType.tel:
      case KycFieldType.phone:
      case KycFieldType.url:
      case KycFieldType.password:
      case KycFieldType.number:
        return _buildTextField(field);
      case KycFieldType.textarea:
        return _buildTextAreaField(field);
      case KycFieldType.date:
      case KycFieldType.datetime:
      case KycFieldType.time:
        return _buildDateField(field);
      case KycFieldType.select:
      case KycFieldType.multiSelect:
        return _buildSelectField(field);
      case KycFieldType.radio:
        return _buildRadioField(field);
      case KycFieldType.checkbox:
        return _buildCheckboxField(field);
      case KycFieldType.file:
      case KycFieldType.image:
        return _buildFileUploadField(field);
      case KycFieldType.identity:
        return _buildIdentityField(field);
      case KycFieldType.address:
        return _buildAddressField(field);
      case KycFieldType.section:
        return _buildSectionHeader(field);
    }
  }

  Widget _buildTextField(KycFieldEntity field) {
    TextInputType keyboardType = TextInputType.text;
    if (field.type == KycFieldType.email) {
      keyboardType = TextInputType.emailAddress;
    } else if (field.type == KycFieldType.number) {
      keyboardType = TextInputType.number;
    } else if (field.type == KycFieldType.tel ||
        field.type == KycFieldType.phone) {
      keyboardType = TextInputType.phone;
    } else if (field.type == KycFieldType.url) {
      keyboardType = TextInputType.url;
    }

    return TextFormField(
      initialValue: _fieldValues[field.id]?.toString(),
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        helperText: field.description,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixText: field.required == true ? '*' : null,
      ),
      keyboardType: keyboardType,
      obscureText: field.type == KycFieldType.password,
      validator: (value) => _validateField(field, value),
      onChanged: (value) {
        _fieldValues[field.id] = value;
      },
    );
  }

  Widget _buildTextAreaField(KycFieldEntity field) {
    return TextFormField(
      initialValue: _fieldValues[field.id]?.toString(),
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        helperText: field.description,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        alignLabelWithHint: true,
      ),
      maxLines: field.rows ?? 4,
      validator: (value) => _validateField(field, value),
      onChanged: (value) {
        _fieldValues[field.id] = value;
      },
    );
  }

  Widget _buildDateField(KycFieldEntity field) {
    final currentValue = _fieldValues[field.id]?.toString();

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: currentValue != null
              ? DateTime.tryParse(currentValue) ?? DateTime.now()
              : DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _fieldValues[field.id] = date.toIso8601String().split('T').first;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: field.label,
          helperText: field.description,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          currentValue ?? 'Select date',
          style: TextStyle(
            color: currentValue != null ? null : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectField(KycFieldEntity field) {
    final options = field.options ?? [];

    return DropdownButtonFormField<String>(
      value: _fieldValues[field.id]?.toString(),
      decoration: InputDecoration(
        labelText: field.label,
        helperText: field.description,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: options
          .map((o) => DropdownMenuItem(value: o.value, child: Text(o.label)))
          .toList(),
      validator: (value) {
        if (field.required == true && (value == null || value.isEmpty)) {
          return '${field.label} is required';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _fieldValues[field.id] = value;
        });
      },
    );
  }

  Widget _buildRadioField(KycFieldEntity field) {
    final options = field.options ?? [];
    final currentValue = _fieldValues[field.id]?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        if (field.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              field.description!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        const SizedBox(height: 8),
        ...options.map((option) => RadioListTile<String>(
              title: Text(option.label),
              value: option.value,
              groupValue: currentValue,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _fieldValues[field.id] = value;
                });
              },
            )),
      ],
    );
  }

  Widget _buildCheckboxField(KycFieldEntity field) {
    final currentValue = _fieldValues[field.id] == true;

    return CheckboxListTile(
      title: Text(field.label),
      subtitle:
          field.description != null ? Text(field.description!) : null,
      value: currentValue,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (value) {
        setState(() {
          _fieldValues[field.id] = value ?? false;
        });
      },
    );
  }

  Widget _buildFileUploadField(KycFieldEntity field) {
    final isUploading = _uploadingFields[field.id] == true;
    final uploadedUrl = _uploadedFiles[field.id] ?? _fieldValues[field.id]?.toString();
    final hasFile = uploadedUrl != null && uploadedUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        if (field.description != null) ...[
          const SizedBox(height: 4),
          Text(
            field.description!,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 8),
        InkWell(
          onTap: isUploading ? null : () => _pickAndUploadFile(field),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: hasFile ? Colors.green.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasFile ? Colors.green.shade300 : Colors.grey.shade300,
                style: hasFile ? BorderStyle.solid : BorderStyle.none,
              ),
            ),
            child: Column(
              children: [
                if (isUploading)
                  const CircularProgressIndicator()
                else if (hasFile)
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 40)
                else
                  Icon(
                    field.type == KycFieldType.image
                        ? Icons.add_a_photo
                        : Icons.upload_file,
                    color: Colors.grey[600],
                    size: 40,
                  ),
                const SizedBox(height: 8),
                Text(
                  isUploading
                      ? 'Uploading...'
                      : hasFile
                          ? 'File uploaded. Tap to replace.'
                          : 'Tap to upload ${field.type == KycFieldType.image ? 'image' : 'file'}',
                  style: TextStyle(
                    color: hasFile ? Colors.green.shade700 : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (field.required == true && !hasFile && !isUploading)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'Required',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
      ],
    );
  }

  Widget _buildIdentityField(KycFieldEntity field) {
    final identityTypes = field.identityTypes ?? [];
    final currentType =
        _fieldValues['${field.id}_type']?.toString() ?? field.defaultType;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (field.description != null) ...[
            const SizedBox(height: 4),
            Text(
              field.description!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 16),

          // Document type selector
          if (identityTypes.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              value: currentType,
              decoration: InputDecoration(
                labelText: 'Document Type',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: identityTypes
                  .map((t) =>
                      DropdownMenuItem(value: t.value, child: Text(t.label)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _fieldValues['${field.id}_type'] = value;
                  // Build identity object
                  _updateIdentityField(field);
                });
              },
            ),
            const SizedBox(height: 16),
          ],

          // Sub-fields for the selected identity type
          if (currentType != null)
            ...(_getIdentitySubFields(field, currentType).map((subField) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildField(subField),
              );
            })),

          // Selfie if required
          if (field.requireSelfie == true) ...[
            const Divider(),
            const SizedBox(height: 8),
            _buildFileUploadField(KycFieldEntity(
              id: '${field.id}_selfie',
              type: KycFieldType.image,
              label: 'Selfie',
              description: 'Take a selfie holding your document',
              required: true,
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressField(KycFieldEntity field) {
    final subFields = field.fields ?? [];
    if (subFields.isEmpty) {
      // Default address fields if none specified
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildTextField(KycFieldEntity(
            id: '${field.id}_street',
            type: KycFieldType.text,
            label: 'Street Address',
            required: field.required,
          )),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(KycFieldEntity(
                  id: '${field.id}_city',
                  type: KycFieldType.text,
                  label: 'City',
                  required: field.required,
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(KycFieldEntity(
                  id: '${field.id}_state',
                  type: KycFieldType.text,
                  label: 'State/Province',
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(KycFieldEntity(
                  id: '${field.id}_zip',
                  type: KycFieldType.text,
                  label: 'Postal Code',
                  required: field.required,
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(KycFieldEntity(
                  id: '${field.id}_country',
                  type: KycFieldType.text,
                  label: 'Country',
                  required: field.required,
                )),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...subFields.map((sub) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildField(sub),
            )),
      ],
    );
  }

  List<KycFieldEntity> _getIdentitySubFields(
      KycFieldEntity field, String typeValue) {
    final identityType = field.identityTypes?.firstWhere(
      (t) => t.value == typeValue,
      orElse: () => field.identityTypes!.first,
    );
    return identityType?.fields ?? [];
  }

  void _updateIdentityField(KycFieldEntity field) {
    final type = _fieldValues['${field.id}_type'];
    if (type == null) return;

    final identityData = <String, dynamic>{
      'type': type,
    };

    // Collect sub-field values
    final subFields = _getIdentitySubFields(field, type);
    for (final sub in subFields) {
      if (_fieldValues.containsKey(sub.id)) {
        identityData[sub.id] = _fieldValues[sub.id];
      }
    }

    if (field.requireSelfie == true &&
        _fieldValues.containsKey('${field.id}_selfie')) {
      identityData['selfie'] = _fieldValues['${field.id}_selfie'];
    }

    _fieldValues[field.id] = identityData;
  }

  Future<void> _pickAndUploadFile(KycFieldEntity field) async {
    final picker = ImagePicker();

    // Show picker options
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );

    if (pickedFile == null || !mounted) return;

    // Upload via bloc
    context.read<KycBloc>().add(KycDocumentUploaded(
          filePath: pickedFile.path,
          fieldId: field.id,
        ));
  }

  String? _validateField(KycFieldEntity field, String? value) {
    if (field.required == true && (value == null || value.trim().isEmpty)) {
      return '${field.label} is required';
    }

    if (value == null || value.isEmpty) return null;

    final validation = field.validation;
    if (validation != null) {
      if (validation.minLength != null &&
          value.length < validation.minLength!) {
        return validation.message ??
            'Minimum ${validation.minLength} characters';
      }
      if (validation.maxLength != null &&
          value.length > validation.maxLength!) {
        return validation.message ??
            'Maximum ${validation.maxLength} characters';
      }
      if (validation.pattern != null) {
        final regex = RegExp(validation.pattern!);
        if (!regex.hasMatch(value)) {
          return validation.message ?? 'Invalid format';
        }
      }
    }

    // Type-specific validation
    if (field.type == KycFieldType.email) {
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    } else if (field.type == KycFieldType.phone ||
        field.type == KycFieldType.tel) {
      final phoneRegex = RegExp(r'^\+?[0-9\s\-().]{7,}$');
      if (!phoneRegex.hasMatch(value)) {
        return 'Please enter a valid phone number';
      }
    }

    return null;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // Check required file uploads
    final fields = widget.level.fields ?? [];
    for (final field in fields) {
      if (field.required == true &&
          (field.type == KycFieldType.file ||
              field.type == KycFieldType.image)) {
        final value = _fieldValues[field.id];
        if (value == null || value.toString().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please upload ${field.label}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    // Build the fields map using field IDs as keys
    final submissionFields = <String, dynamic>{};
    for (final field in fields) {
      if (field.hidden == true || field.type == KycFieldType.section) continue;

      final value = _fieldValues[field.id];
      if (value != null) {
        submissionFields[field.id] = value;
      }

      // For identity fields, build the composite object
      if (field.type == KycFieldType.identity) {
        _updateIdentityField(field);
        submissionFields[field.id] = _fieldValues[field.id];
      }

      // For address fields, build composite object
      if (field.type == KycFieldType.address) {
        final addressData = <String, dynamic>{};
        final subFields = field.fields;
        if (subFields != null) {
          for (final sub in subFields) {
            if (_fieldValues.containsKey(sub.id)) {
              addressData[sub.id] = _fieldValues[sub.id];
            }
          }
        } else {
          // Default address sub-fields
          for (final suffix in ['street', 'city', 'state', 'zip', 'country']) {
            final key = '${field.id}_$suffix';
            if (_fieldValues.containsKey(key)) {
              addressData[suffix] = _fieldValues[key];
            }
          }
        }
        submissionFields[field.id] = addressData;
      }
    }

    if (widget.existingApplication != null) {
      context.read<KycBloc>().add(KycApplicationUpdated(
            applicationId: widget.existingApplication!.id,
            fields: submissionFields,
          ));
    } else {
      context.read<KycBloc>().add(KycApplicationSubmitted(
            levelId: widget.level.id,
            fields: submissionFields,
          ));
    }
  }
}
