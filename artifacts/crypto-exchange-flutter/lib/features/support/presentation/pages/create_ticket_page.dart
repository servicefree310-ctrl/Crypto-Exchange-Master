import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/create_ticket_params.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../bloc/support_tickets_bloc.dart';

class CreateTicketPage extends StatelessWidget {
  const CreateTicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SupportTicketsBloc>(),
      child: const CreateTicketView(),
    );
  }
}

class CreateTicketView extends StatefulWidget {
  const CreateTicketView({super.key});

  @override
  State<CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<CreateTicketView> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _tagController = TextEditingController();

  TicketImportance _selectedImportance = TicketImportance.low;
  final List<TicketImportance> _importanceOptions = [
    TicketImportance.low,
    TicketImportance.medium,
    TicketImportance.high
  ];
  final List<String> _tags = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Create Support Ticket',
          style: context.h5.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<SupportTicketsBloc, SupportTicketsState>(
        listener: (context, state) {
          if (state is SupportTicketCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Ticket created successfully: ${state.ticket.subject}'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          } else if (state is SupportTicketsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isSubmitting = false;
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject Field
                _buildSectionTitle('Subject'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _subjectController,
                  hintText: 'Enter ticket subject',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Subject is required';
                    }
                    if (value.trim().length < 5) {
                      return 'Subject must be at least 5 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Priority Field
                _buildSectionTitle('Priority'),
                const SizedBox(height: 8),
                _buildPrioritySelector(),

                const SizedBox(height: 24),

                // Tags Field
                _buildSectionTitle('Tags'),
                const SizedBox(height: 8),
                _buildTagsField(),

                const SizedBox(height: 24),

                // Message Field
                _buildSectionTitle('Message'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _messageController,
                  hintText: 'Describe your issue in detail...',
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Message is required';
                    }
                    if (value.trim().length < 10) {
                      return 'Message must be at least 10 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Create Ticket',
                            style: context.buttonText(color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: context.h6.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: context.textPrimary),
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: context.textTertiary),
        filled: true,
        fillColor: context.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.priceDownColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.priceDownColor),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: DropdownButtonFormField<TicketImportance>(
        value: _selectedImportance,
        style: TextStyle(color: context.textPrimary),
        dropdownColor: context.cardBackground,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        items: _importanceOptions.map((importance) {
          return DropdownMenuItem(
            value: importance,
            child: Row(
              children: [
                _getPriorityIcon(importance),
                const SizedBox(width: 8),
                Text(
                  _getImportanceDisplayName(importance),
                  style: TextStyle(
                    color: _getPriorityColor(importance),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedImportance = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag input field
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagController,
                style: TextStyle(color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Add a tag',
                  hintStyle: TextStyle(color: context.textTertiary),
                  filled: true,
                  fillColor: context.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.primary),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                onFieldSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => _addTag(_tagController.text),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Tags display
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.colors.primary),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: TextStyle(
                        color: context.colors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _removeTag(tag),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  String _getImportanceDisplayName(TicketImportance importance) {
    switch (importance) {
      case TicketImportance.low:
        return 'LOW';
      case TicketImportance.medium:
        return 'MEDIUM';
      case TicketImportance.high:
        return 'HIGH';
    }
  }

  Widget _getPriorityIcon(TicketImportance importance) {
    switch (importance) {
      case TicketImportance.low:
        return const Icon(Icons.arrow_downward, color: Colors.green, size: 16);
      case TicketImportance.medium:
        return const Icon(Icons.remove, color: Colors.orange, size: 16);
      case TicketImportance.high:
        return const Icon(Icons.arrow_upward, color: Colors.red, size: 16);
    }
  }

  Color _getPriorityColor(TicketImportance importance) {
    switch (importance) {
      case TicketImportance.low:
        return Colors.green;
      case TicketImportance.medium:
        return Colors.orange;
      case TicketImportance.high:
        return Colors.red;
    }
  }

  void _submitTicket() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final params = CreateTicketParams(
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      importance: _selectedImportance,
      tags: _tags,
    );

    context.read<SupportTicketsBloc>().add(
          CreateSupportTicketRequested(params),
        );
  }
}
