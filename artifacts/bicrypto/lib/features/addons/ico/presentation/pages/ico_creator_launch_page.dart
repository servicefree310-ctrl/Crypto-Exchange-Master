import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/injection/injection.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';
import 'package:mobile/features/addons/ico_creator/presentation/bloc/creator_bloc.dart';
import 'package:mobile/features/addons/ico_creator/presentation/bloc/creator_event.dart';
import 'package:mobile/features/addons/ico_creator/presentation/bloc/creator_state.dart';
import 'package:mobile/features/addons/ico_creator/presentation/bloc/launch_plan_cubit.dart';
import 'package:mobile/features/addons/ico_creator/domain/entities/launch_plan_entity.dart';
import 'package:mobile/features/wallet/domain/entities/wallet_entity.dart';
import 'package:mobile/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class IcoCreatorLaunchPage extends StatelessWidget {
  const IcoCreatorLaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LaunchPlanCubit>()..fetchPlans(),
      child: const IcoCreatorLaunchView(),
    );
  }
}

class IcoCreatorLaunchView extends StatefulWidget {
  const IcoCreatorLaunchView({super.key});

  @override
  State<IcoCreatorLaunchView> createState() => _IcoCreatorLaunchViewState();
}

class _IcoCreatorLaunchViewState extends State<IcoCreatorLaunchView> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const String _draftKey = 'ico_launch_draft';
  Timer? _autoSaveTimer;

  // Form data
  final _formData = <String, dynamic>{
    'name': '',
    'symbol': '',
    'icon': '',
    'tokenType': 'Utility',
    'blockchain': 'Ethereum',
    'totalSupply': 0.0,
    'description': '',
    'tokenDetails': {
      'whitepaper': '',
      'github': '',
      'twitter': '',
      'telegram': '',
      'useOfFunds': <String>[],
    },
    'teamMembers': <Map<String, String>>[],
    'roadmap': <Map<String, dynamic>>[],
    'website': '',
    'targetAmount': 0.0,
    'startDate': DateTime.now(),
    'phases': <Map<String, dynamic>>[
      {
        'id': '1',
        'name': 'Seed Round',
        'tokenPrice': 0.01,
        'allocation': 0.0,
        'durationDays': 30,
      }
    ],
    'termsAccepted': false,
    'selectedPlan': null,
    'paymentComplete': false,
  };

  // Steps
  final _steps = [
    'Basic Info',
    'Tokenomics',
    'Resources',
    'Team',
    'Roadmap',
    'Offering',
    'Launch Plan',
    'Payment',
    'Review',
  ];

  @override
  void initState() {
    super.initState();
    _loadDraft();
    // Auto-save every 30 seconds
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _saveDraft();
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftString = prefs.getString(_draftKey);

      if (draftString != null) {
        final draftData = json.decode(draftString) as Map<String, dynamic>;

        // Show dialog asking if user wants to resume from draft
        if (mounted) {
          final shouldResume = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Resume from Draft?'),
                  content: const Text(
                    'We found a saved draft of your token launch. Would you like to continue where you left off?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                        _clearDraft();
                      },
                      child: const Text('Start Fresh'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                      ),
                      child: const Text('Resume Draft'),
                    ),
                  ],
                ),
              ) ??
              false;

          if (shouldResume) {
            setState(() {
              // Restore form data
              _formData.addAll(draftData['formData'] as Map<String, dynamic>);

              // Convert date strings back to DateTime
              if (_formData['startDate'] is String) {
                _formData['startDate'] =
                    DateTime.parse(_formData['startDate'] as String);
              }

              // Convert roadmap dates
              final roadmap = _formData['roadmap'] as List<dynamic>;
              for (var item in roadmap) {
                if (item['date'] is String) {
                  item['date'] = DateTime.parse(item['date'] as String);
                }
              }

              // Restore step position
              _currentStep = draftData['currentStep'] as int? ?? 0;

              // Navigate to saved step
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _pageController.jumpToPage(_currentStep);
              });
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Draft restored successfully'),
                backgroundColor: context.priceUpColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      // Failed to load draft, silently continue
      debugPrint('Failed to load draft: $e');
    }
  }

  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Create a copy of form data for serialization
      final dataToSave = Map<String, dynamic>.from(_formData);

      // Convert DateTime to string for JSON serialization
      if (dataToSave['startDate'] is DateTime) {
        dataToSave['startDate'] =
            (dataToSave['startDate'] as DateTime).toIso8601String();
      }

      // Convert roadmap dates
      final roadmap =
          List<Map<String, dynamic>>.from(dataToSave['roadmap'] as List);
      for (var item in roadmap) {
        if (item['date'] is DateTime) {
          item['date'] = (item['date'] as DateTime).toIso8601String();
        }
      }
      dataToSave['roadmap'] = roadmap;

      // Don't save the selected plan object, just its ID
      if (dataToSave['selectedPlan'] is LaunchPlanEntity) {
        dataToSave['selectedPlanId'] =
            (dataToSave['selectedPlan'] as LaunchPlanEntity).id;
        dataToSave.remove('selectedPlan');
      }

      final draftData = {
        'formData': dataToSave,
        'currentStep': _currentStep,
        'savedAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_draftKey, json.encode(draftData));

      // Show brief toast notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft saved'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to save draft: $e');
    }
  }

  Future<void> _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (e) {
      debugPrint('Failed to clear draft: $e');
    }
  }

  void _updateFormData(String key, dynamic value) {
    setState(() {
      if (key.contains('.')) {
        // Handle nested keys like 'tokenDetails.whitepaper'
        final keys = key.split('.');
        Map<String, dynamic> current = _formData;
        for (int i = 0; i < keys.length - 1; i++) {
          current = current[keys[i]] as Map<String, dynamic>;
        }
        current[keys.last] = value;
      } else {
        _formData[key] = value;
      }
    });

    // Save draft after each update
    _saveDraft();
  }

  void _nextStep() {
    // Validate current step before proceeding
    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete all required fields'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic Info
        final name = _formData['name'] as String;
        final symbol = _formData['symbol'] as String;
        final website = _formData['website'] as String;
        return name.length >= 2 &&
            symbol.length >= 2 &&
            symbol.length <= 8 &&
            website.isNotEmpty;

      case 1: // Tokenomics
        final totalSupply = _formData['totalSupply'] as double;
        final targetAmount = _formData['targetAmount'] as double;
        final description = _formData['description'] as String;
        return totalSupply > 0 && targetAmount > 0 && description.length >= 50;

      case 2: // Resources
        final tokenDetails = _formData['tokenDetails'] as Map<String, dynamic>;
        final whitepaper = tokenDetails['whitepaper'] as String;
        final github = tokenDetails['github'] as String;
        final twitter = tokenDetails['twitter'] as String;
        final telegram = tokenDetails['telegram'] as String;
        final useOfFunds = tokenDetails['useOfFunds'] as List<String>;
        return whitepaper.isNotEmpty &&
            github.isNotEmpty &&
            twitter.isNotEmpty &&
            telegram.isNotEmpty &&
            useOfFunds.isNotEmpty;

      case 3: // Team
        final teamMembers = _formData['teamMembers'] as List;
        return teamMembers.isNotEmpty;

      case 4: // Roadmap
        final roadmap = _formData['roadmap'] as List;
        return roadmap.isNotEmpty;

      case 5: // Offering
        final phases = _formData['phases'] as List;
        return phases.isNotEmpty &&
            phases.every((phase) {
              final allocation = phase['allocation'] as double;
              final tokenPrice = phase['tokenPrice'] as double;
              return allocation > 0 && tokenPrice > 0;
            });

      case 6: // Launch Plan
        return _formData['selectedPlan'] != null;

      case 7: // Payment
        return _formData['paymentComplete'] as bool;

      case 8: // Review
        return _formData['termsAccepted'] as bool;

      default:
        return true;
    }
  }

  void _submit() {
    final payload = {
      ..._formData,
      'selectedPlan': (_formData['selectedPlan'] as LaunchPlanEntity?)?.id,
      'startDate': (_formData['startDate'] as DateTime).toIso8601String(),
    };

    context.read<CreatorBloc>().add(CreatorLaunchTokenRequested(payload));

    // Clear draft on successful submission
    _clearDraft();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return BlocListener<CreatorBloc, CreatorState>(
      listener: (context, state) {
        if (state is CreatorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colors.error,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _submit,
              ),
            ),
          );
        } else if (state is CreatorLaunchSuccess) {
          // Show success page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => _SuccessPage(
                tokenName: _formData['name'] as String,
                tokenSymbol: _formData['symbol'] as String,
              ),
            ),
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: context.colors.surface,
            appBar: AppBar(
              backgroundColor: context.colors.surface,
              elevation: 0,
              title: Text(
                'Launch Token',
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: context.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                // Progress indicator
                _buildProgressIndicator(),

                // Form content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _BasicInfoStep(
                        formData: _formData,
                        onUpdate: _updateFormData,
                      ),
                      _TokenomicsStep(
                        formData: _formData,
                        onUpdate: _updateFormData,
                      ),
                      _ResourcesStep(
                        formData: _formData,
                        onUpdate: _updateFormData,
                      ),
                      _TeamStep(
                        formData: _formData,
                        onUpdate: _updateFormData,
                      ),
                      _RoadmapStep(
                        formData: _formData,
                        onUpdate: _updateFormData,
                      ),
                      _OfferingStep(
                        formData: _formData,
                        onUpdate: _updateFormData,
                      ),
                      _LaunchPlanStep(
                        formData: _formData,
                        onUpdate: _updateFormData,
                      ),
                      _PaymentStep(
                        formData: _formData,
                        onUpdate: _updateFormData,
                      ),
                      _ReviewStep(
                        formData: _formData,
                        onUpdate: _updateFormData,
                      ),
                    ],
                  ),
                ),

                // Navigation buttons
                _buildNavigationButtons(),
              ],
            ),
          ),

          // Loading overlay
          BlocBuilder<CreatorBloc, CreatorState>(
            builder: (context, state) {
              if (state is CreatorLaunching) {
                return Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: context.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.colors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Launching your token...',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please wait while we process your request',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: context.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final isDark = context.isDarkMode;

    return Container(
      color: isDark ? Colors.black : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _steps.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: index == _currentStep ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: index <= _currentStep
                        ? context.colors.primary
                        : isDark
                            ? Colors.white24
                            : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Step title
          Text(
            'Step ${_currentStep + 1} of ${_steps.length}: ${_steps[_currentStep]}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isDark = context.isDarkMode;
    final isLastStep = _currentStep == _steps.length - 1;
    final isSubmitting = context.watch<CreatorBloc>().state is CreatorLaunching;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: isSubmitting ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : isLastStep
                      ? _submit
                      : _nextStep,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: context.colors.primary,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isLastStep ? 'Submit' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Step 1: Basic Info
class _BasicInfoStep extends StatefulWidget {
  const _BasicInfoStep({
    required this.formData,
    required this.onUpdate,
  });

  final Map<String, dynamic> formData;
  final void Function(String, dynamic) onUpdate;

  @override
  State<_BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<_BasicInfoStep> {
  final Map<String, String> _errors = {};

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      setState(() => _errors['name'] = 'Token name is required');
      return 'Token name is required';
    }
    if (value.length < 2) {
      setState(
          () => _errors['name'] = 'Token name must be at least 2 characters');
      return 'Token name must be at least 2 characters';
    }
    setState(() => _errors.remove('name'));
    return null;
  }

  String? _validateSymbol(String? value) {
    if (value == null || value.isEmpty) {
      setState(() => _errors['symbol'] = 'Token symbol is required');
      return 'Token symbol is required';
    }
    if (value.length < 2) {
      setState(() =>
          _errors['symbol'] = 'Token symbol must be at least 2 characters');
      return 'Token symbol must be at least 2 characters';
    }
    if (value.length > 8) {
      setState(() =>
          _errors['symbol'] = 'Token symbol must be at most 8 characters');
      return 'Token symbol must be at most 8 characters';
    }
    setState(() => _errors.remove('symbol'));
    return null;
  }

  String? _validateUrl(String? value, String field) {
    if (value == null || value.isEmpty) {
      setState(() => _errors.remove(field));
      return null; // Optional field
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      setState(() => _errors[field] = 'Invalid URL format');
      return 'Invalid URL format';
    }
    setState(() => _errors.remove(field));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your token project',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.textSecondary,
                ),
          ),
          const SizedBox(height: 24),

          // Token Name
          _buildTextField(
            context,
            label: 'Token Name',
            hint: 'e.g., My Awesome Token',
            value: widget.formData['name'] as String,
            onChanged: (value) => widget.onUpdate('name', value),
            validator: _validateName,
            errorText: _errors['name'],
          ),
          const SizedBox(height: 16),

          // Token Symbol
          _buildTextField(
            context,
            label: 'Token Symbol',
            hint: 'e.g., MAT',
            value: widget.formData['symbol'] as String,
            onChanged: (value) =>
                widget.onUpdate('symbol', value.toUpperCase()),
            textCapitalization: TextCapitalization.characters,
            maxLength: 8,
            validator: _validateSymbol,
            errorText: _errors['symbol'],
          ),
          const SizedBox(height: 16),

          // Blockchain
          _buildDropdown(
            context,
            label: 'Blockchain',
            value: widget.formData['blockchain'] as String,
            items: ['Ethereum', 'Binance Smart Chain', 'Polygon', 'Avalanche'],
            onChanged: (value) => widget.onUpdate('blockchain', value),
          ),
          const SizedBox(height: 16),

          // Token Type
          _buildDropdown(
            context,
            label: 'Token Type',
            value: widget.formData['tokenType'] as String,
            items: ['Utility', 'Governance', 'Security', 'Payment'],
            onChanged: (value) => widget.onUpdate('tokenType', value),
          ),
          const SizedBox(height: 16),

          // Website
          _buildTextField(
            context,
            label: 'Website',
            hint: 'https://yourproject.com',
            value: widget.formData['website'] as String,
            onChanged: (value) => widget.onUpdate('website', value),
            keyboardType: TextInputType.url,
            validator: (value) => _validateUrl(value, 'website'),
            errorText: _errors['website'],
          ),
          const SizedBox(height: 16),

          // Icon URL
          _buildTextField(
            context,
            label: 'Icon URL (optional)',
            hint: 'https://yourproject.com/icon.png',
            value: widget.formData['icon'] as String,
            onChanged: (value) => widget.onUpdate('icon', value),
            keyboardType: TextInputType.url,
            validator: (value) => _validateUrl(value, 'icon'),
            errorText: _errors['icon'],
          ),
        ],
      ),
    );
  }
}

// Step 2: Tokenomics
class _TokenomicsStep extends StatelessWidget {
  const _TokenomicsStep({
    required this.formData,
    required this.onUpdate,
  });

  final Map<String, dynamic> formData;
  final void Function(String, dynamic) onUpdate;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Token Economics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define your token supply and fundraising target',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.textSecondary,
                ),
          ),
          const SizedBox(height: 24),

          // Total Supply
          _buildTextField(
            context,
            label: 'Total Supply',
            hint: 'e.g., 1000000000',
            value: formData['totalSupply'].toString(),
            onChanged: (value) => onUpdate(
              'totalSupply',
              double.tryParse(value) ?? 0,
            ),
            keyboardType: TextInputType.number,
            suffix: formData['symbol'] as String,
          ),
          const SizedBox(height: 16),

          // Target Amount
          _buildTextField(
            context,
            label: 'Target Amount (USD)',
            hint: 'e.g., 500000',
            value: formData['targetAmount'].toString(),
            onChanged: (value) => onUpdate(
              'targetAmount',
              double.tryParse(value) ?? 0,
            ),
            keyboardType: TextInputType.number,
            prefix: '\$',
          ),
          const SizedBox(height: 16),

          // Start Date
          _buildDatePicker(
            context,
            label: 'Start Date',
            value: formData['startDate'] as DateTime,
            onChanged: (date) => onUpdate('startDate', date),
          ),
          const SizedBox(height: 24),

          // Description
          _buildTextField(
            context,
            label: 'Project Description',
            hint: 'Describe your project in detail (min 50 characters)',
            value: formData['description'] as String,
            onChanged: (value) => onUpdate('description', value),
            maxLines: 6,
            minLines: 4,
          ),
        ],
      ),
    );
  }
}

// Step 3: Resources
class _ResourcesStep extends StatelessWidget {
  const _ResourcesStep({
    required this.formData,
    required this.onUpdate,
  });

  final Map<String, dynamic> formData;
  final void Function(String, dynamic) onUpdate;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final tokenDetails = formData['tokenDetails'] as Map<String, dynamic>;
    final useOfFunds = tokenDetails['useOfFunds'] as List<String>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Resources',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Links and resource allocation',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.textSecondary,
                ),
          ),
          const SizedBox(height: 24),

          // Whitepaper
          _buildTextField(
            context,
            label: 'Whitepaper URL',
            hint: 'https://yourproject.com/whitepaper.pdf',
            value: tokenDetails['whitepaper'] as String,
            onChanged: (value) => onUpdate('tokenDetails.whitepaper', value),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),

          // GitHub
          _buildTextField(
            context,
            label: 'GitHub Repository',
            hint: 'https://github.com/yourproject',
            value: tokenDetails['github'] as String,
            onChanged: (value) => onUpdate('tokenDetails.github', value),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),

          // Twitter
          _buildTextField(
            context,
            label: 'Twitter/X',
            hint: 'https://twitter.com/yourproject',
            value: tokenDetails['twitter'] as String,
            onChanged: (value) => onUpdate('tokenDetails.twitter', value),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),

          // Telegram
          _buildTextField(
            context,
            label: 'Telegram',
            hint: 'https://t.me/yourproject',
            value: tokenDetails['telegram'] as String,
            onChanged: (value) => onUpdate('tokenDetails.telegram', value),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 24),

          // Use of Funds
          Text(
            'Use of Funds',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...useOfFunds.map((fund) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Chip(
                  label: Text(fund),
                  onDeleted: () {
                    final newFunds = List<String>.from(useOfFunds)
                      ..remove(fund);
                    onUpdate('tokenDetails.useOfFunds', newFunds);
                  },
                ),
              )),
          TextButton.icon(
            onPressed: () => _showAddFundDialog(context, useOfFunds),
            icon: const Icon(Icons.add),
            label: const Text('Add Use of Funds'),
          ),
        ],
      ),
    );
  }

  void _showAddFundDialog(BuildContext context, List<String> currentFunds) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Use of Funds'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Fund allocation',
            hintText: 'e.g., Development, Marketing',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final newFunds = List<String>.from(currentFunds)
                  ..add(controller.text.trim());
                onUpdate('tokenDetails.useOfFunds', newFunds);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Step 4: Team
class _TeamStep extends StatelessWidget {
  const _TeamStep({
    required this.formData,
    required this.onUpdate,
  });

  final Map<String, dynamic> formData;
  final void Function(String, dynamic) onUpdate;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final teamMembers = formData['teamMembers'] as List<Map<String, String>>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Members',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your core team members',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          if (teamMembers.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: context.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No team members added yet',
                    style: TextStyle(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...teamMembers.map((member) => _buildTeamMemberCard(
                  context,
                  member,
                  onRemove: () {
                    final newTeam = List<Map<String, String>>.from(teamMembers)
                      ..remove(member);
                    onUpdate('teamMembers', newTeam);
                  },
                )),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showAddTeamMemberDialog(context, teamMembers),
              icon: const Icon(Icons.add),
              label: const Text('Add Team Member'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(BuildContext context, Map<String, String> member,
      {required VoidCallback onRemove}) {
    final isDark = context.isDarkMode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: context.cardBackground,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.colors.primary.withValues(alpha: 0.1),
          child: Text(
            member['name']!.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(member['name']!),
        subtitle: Text(member['role']!),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: context.colors.error),
          onPressed: onRemove,
        ),
      ),
    );
  }

  void _showAddTeamMemberDialog(
    BuildContext context,
    List<Map<String, String>> currentTeam,
  ) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final bioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Team Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'John Doe',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  hintText: 'CEO & Founder',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Brief description...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty &&
                  roleController.text.trim().isNotEmpty &&
                  bioController.text.trim().isNotEmpty) {
                final newTeam = List<Map<String, String>>.from(currentTeam)
                  ..add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameController.text.trim(),
                    'role': roleController.text.trim(),
                    'bio': bioController.text.trim(),
                  });
                onUpdate('teamMembers', newTeam);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Step 5: Roadmap
class _RoadmapStep extends StatelessWidget {
  const _RoadmapStep({
    required this.formData,
    required this.onUpdate,
  });

  final Map<String, dynamic> formData;
  final void Function(String, dynamic) onUpdate;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final roadmap = formData['roadmap'] as List<Map<String, dynamic>>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Roadmap',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define your project milestones',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          if (roadmap.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.timeline_outlined,
                    size: 64,
                    color: context.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No roadmap items added yet',
                    style: TextStyle(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...roadmap.map((item) => _buildRoadmapCard(
                  context,
                  item,
                  onRemove: () {
                    final newRoadmap = List<Map<String, dynamic>>.from(roadmap)
                      ..remove(item);
                    onUpdate('roadmap', newRoadmap);
                  },
                )),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showAddRoadmapDialog(context, roadmap),
              icon: const Icon(Icons.add),
              label: const Text('Add Milestone'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapCard(BuildContext context, Map<String, dynamic> item,
      {required VoidCallback onRemove}) {
    final isDark = context.isDarkMode;
    final date = item['date'] as DateTime;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: context.cardBackground,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.flag,
              color: context.colors.primary,
              size: 20,
            ),
          ),
        ),
        title: Text(item['title'] as String),
        subtitle: Text(
          '${date.day}/${date.month}/${date.year}',
          style: TextStyle(
            color: context.textSecondary,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: context.colors.error),
          onPressed: onRemove,
        ),
      ),
    );
  }

  void _showAddRoadmapDialog(
    BuildContext context,
    List<Map<String, dynamic>> currentRoadmap,
  ) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Milestone'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Alpha Launch',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Release alpha version...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Target Date'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 1825)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty &&
                  descriptionController.text.trim().isNotEmpty) {
                final newRoadmap =
                    List<Map<String, dynamic>>.from(currentRoadmap)
                      ..add({
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'title': titleController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'date': selectedDate,
                        'completed': false,
                      });
                onUpdate('roadmap', newRoadmap);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Step 6: Offering Structure
class _OfferingStep extends StatelessWidget {
  const _OfferingStep({
    required this.formData,
    required this.onUpdate,
  });

  final Map<String, dynamic> formData;
  final void Function(String, dynamic) onUpdate;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final phases = formData['phases'] as List<Map<String, dynamic>>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Offering Structure',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define your token sale phases',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          ...phases.asMap().entries.map((entry) => _buildPhaseCard(
                context,
                entry.key,
                entry.value,
              )),
          if (phases.length < 3) ...[
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  final newPhases = List<Map<String, dynamic>>.from(phases)
                    ..add({
                      'id': '${phases.length + 1}',
                      'name': 'Phase ${phases.length + 1}',
                      'tokenPrice': 0.01,
                      'allocation': 0.0,
                      'durationDays': 30,
                    });
                  onUpdate('phases', newPhases);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Phase'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhaseCard(
    BuildContext context,
    int index,
    Map<String, dynamic> phase,
  ) {
    final isDark = context.isDarkMode;
    final phases = formData['phases'] as List<Map<String, dynamic>>;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: context.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phase ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (phases.length > 1)
                  IconButton(
                    icon: Icon(Icons.delete, color: context.colors.error),
                    onPressed: () {
                      final newPhases = List<Map<String, dynamic>>.from(phases)
                        ..removeAt(index);
                      onUpdate('phases', newPhases);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Phase Name
            _buildTextField(
              context,
              label: 'Phase Name',
              hint: 'e.g., Seed Round',
              value: phase['name'] as String,
              onChanged: (value) {
                final newPhases = List<Map<String, dynamic>>.from(phases);
                newPhases[index] = {...phase, 'name': value};
                onUpdate('phases', newPhases);
              },
            ),
            const SizedBox(height: 16),

            // Token Price
            _buildTextField(
              context,
              label: 'Token Price (USD)',
              hint: 'e.g., 0.01',
              value: phase['tokenPrice'].toString(),
              onChanged: (value) {
                final newPhases = List<Map<String, dynamic>>.from(phases);
                newPhases[index] = {
                  ...phase,
                  'tokenPrice': double.tryParse(value) ?? 0,
                };
                onUpdate('phases', newPhases);
              },
              keyboardType: TextInputType.number,
              prefix: '\$',
            ),
            const SizedBox(height: 16),

            // Allocation
            _buildTextField(
              context,
              label: 'Token Allocation',
              hint: 'e.g., 10000000',
              value: phase['allocation'].toString(),
              onChanged: (value) {
                final newPhases = List<Map<String, dynamic>>.from(phases);
                newPhases[index] = {
                  ...phase,
                  'allocation': double.tryParse(value) ?? 0,
                };
                onUpdate('phases', newPhases);
              },
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Duration
            _buildTextField(
              context,
              label: 'Duration (days)',
              hint: 'e.g., 30',
              value: phase['durationDays'].toString(),
              onChanged: (value) {
                final newPhases = List<Map<String, dynamic>>.from(phases);
                newPhases[index] = {
                  ...phase,
                  'durationDays': int.tryParse(value) ?? 0,
                };
                onUpdate('phases', newPhases);
              },
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}

// Step 7: Launch Plan Selection
class _LaunchPlanStep extends StatelessWidget {
  const _LaunchPlanStep({
    required this.formData,
    required this.onUpdate,
  });

  final Map<String, dynamic> formData;
  final void Function(String, dynamic) onUpdate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LaunchPlanCubit, LaunchPlanState>(
      builder: (context, state) {
        if (state is LaunchPlanLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LaunchPlanError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<LaunchPlanCubit>().fetchPlans(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is LaunchPlanLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Your Launch Plan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the plan that best fits your needs',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                ...state.plans.map((plan) => _buildPlanCard(
                      context,
                      plan,
                      isSelected: formData['selectedPlan'] == plan,
                    )),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPlanCard(BuildContext context, LaunchPlanEntity plan,
      {required bool isSelected}) {
    final isDark = context.isDarkMode;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isSelected
          ? context.colors.primary.withValues(alpha: 0.1)
          : context.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? context.colors.primary : context.dividerColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => onUpdate('selectedPlan', plan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? context.colors.primary : null,
                        ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: context.colors.primary,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                plan.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                '\$${plan.price.toStringAsFixed(0)} ${plan.currency}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
              ),
              const SizedBox(height: 16),

              // Features
              ...plan.features.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          size: 16,
                          color: context.priceUpColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_formatFeatureName(entry.key)}: ${entry.value}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFeatureName(String key) {
    return key
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => ' ${match.group(0)}',
        )
        .trim()
        .split(' ')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }
}

// Step 8: Payment
class _PaymentStep extends StatefulWidget {
  const _PaymentStep({
    required this.formData,
    required this.onUpdate,
  });

  final Map<String, dynamic> formData;
  final void Function(String, dynamic) onUpdate;

  @override
  State<_PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<_PaymentStep> {
  bool _isLoadingWallet = true;
  double _walletBalance = 0.0;
  String? _walletError;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    final plan = widget.formData['selectedPlan'] as LaunchPlanEntity?;

    if (plan == null) {
      setState(() {
        _walletError = 'Please select a launch plan first';
        _isLoadingWallet = false;
      });
      return;
    }

    try {
      final walletRepository = getIt<WalletRepository>();
      final walletType = _getWalletType(plan.walletType);
      final result =
          await walletRepository.getWallet(walletType, plan.currency);

      result.fold(
        (failure) {
          setState(() {
            _walletError = failure.message;
            _isLoadingWallet = false;
          });
        },
        (wallet) {
          setState(() {
            _walletBalance = wallet.balance;
            _isLoadingWallet = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _walletError = 'Failed to load wallet balance';
        _isLoadingWallet = false;
      });
    }
  }

  WalletType _getWalletType(String type) {
    switch (type.toUpperCase()) {
      case 'SPOT':
        return WalletType.SPOT;
      case 'FUNDING':
        return WalletType.FIAT;
      case 'ECO':
        return WalletType.ECO;
      case 'FUTURES':
        return WalletType.FUTURES;
      default:
        return WalletType.SPOT;
    }
  }

  void _handleCompletePayment() {
    final plan = widget.formData['selectedPlan'] as LaunchPlanEntity?;
    if (plan == null || _walletBalance < plan.price) return;

    // Show payment confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'You are about to pay ${plan.price} ${plan.currency} for the ${plan.name} plan.'),
            const SizedBox(height: 16),
            Text(
              'This amount will be deducted from your wallet immediately.',
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onUpdate('paymentComplete', true);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Payment completed successfully'),
                  backgroundColor: context.priceUpColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
            ),
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final plan = widget.formData['selectedPlan'] as LaunchPlanEntity?;
    final isPaymentComplete = widget.formData['paymentComplete'] as bool;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your payment to launch your token',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.textSecondary,
                ),
          ),
          const SizedBox(height: 24),

          // Wallet and plan details
          if (_isLoadingWallet)
            const Center(child: CircularProgressIndicator())
          else if (_walletError != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: context.colors.error.withValues(alpha: 0.3)),
              ),
              child: Text(
                _walletError!,
                style: TextStyle(color: context.colors.error),
              ),
            )
          else if (plan != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Wallet Balance',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondary,
                        ),
                      ),
                      Text(
                        '${_walletBalance.toStringAsFixed(2)} ${plan.currency}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _walletBalance >= plan.price
                                      ? context.priceUpColor
                                      : context.colors.error,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Plan Cost',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondary,
                        ),
                      ),
                      Text(
                        '${plan.price.toStringAsFixed(2)} ${plan.currency}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  if (_walletBalance < plan.price) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: context.colors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Insufficient balance. Please deposit funds to continue.',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.colors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Terms acceptance
          CheckboxListTile(
            value: widget.formData['termsAccepted'] as bool,
            onChanged: isPaymentComplete
                ? null
                : (value) => widget.onUpdate('termsAccepted', value ?? false),
            title: const Text('I accept the terms and conditions'),
            subtitle: Text(
              'By accepting, you agree to our platform terms and conditions',
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondary,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 24),

          // Payment button or status
          if (isPaymentComplete)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.priceUpColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: context.priceUpColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: context.priceUpColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Payment completed successfully',
                    style: TextStyle(
                      color: context.priceUpColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: plan != null &&
                        _walletBalance >= plan.price &&
                        widget.formData['termsAccepted'] as bool
                    ? _handleCompletePayment
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: context.colors.primary,
                ),
                child: Text(
                  _walletBalance >= (plan?.price ?? 0)
                      ? 'Complete Payment'
                      : 'Insufficient Balance',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Step 9: Review & Submit
class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.formData,
    required this.onUpdate,
  });

  final Map<String, dynamic> formData;
  final void Function(String, dynamic) onUpdate;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final plan = formData['selectedPlan'] as LaunchPlanEntity?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Submit',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your information before submitting',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.textSecondary,
                ),
          ),
          const SizedBox(height: 24),

          // Summary sections
          _buildSummarySection(
            context,
            title: 'Basic Information',
            items: [
              'Name: ${formData['name']}',
              'Symbol: ${formData['symbol']}',
              'Blockchain: ${formData['blockchain']}',
              'Type: ${formData['tokenType']}',
            ],
          ),

          _buildSummarySection(
            context,
            title: 'Tokenomics',
            items: [
              'Total Supply: ${_formatNumber(formData['totalSupply'] as double)} ${formData['symbol']}',
              'Target: \$${_formatNumber(formData['targetAmount'] as double)}',
              'Start: ${_formatDate(formData['startDate'] as DateTime)}',
            ],
          ),

          _buildSummarySection(
            context,
            title: 'Team & Roadmap',
            items: [
              'Team Members: ${(formData['teamMembers'] as List).length}',
              'Roadmap Items: ${(formData['roadmap'] as List).length}',
            ],
          ),

          if (plan != null)
            _buildSummarySection(
              context,
              title: 'Selected Plan',
              items: [
                plan.name,
                'Fee: \$${plan.price.toStringAsFixed(0)} ${plan.currency}',
              ],
            ),

          const SizedBox(height: 24),

          // Terms acceptance
          CheckboxListTile(
            value: formData['termsAccepted'] as bool,
            onChanged: (value) => onUpdate('termsAccepted', value ?? false),
            title: const Text('I accept the terms and conditions'),
            subtitle: Text(
              'By submitting, you agree to our platform terms',
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondary,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context, {
    required String title,
    required List<String> items,
  }) {
    final isDark = context.isDarkMode;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Success Page
class _SuccessPage extends StatelessWidget {
  const _SuccessPage({
    required this.tokenName,
    required this.tokenSymbol,
  });

  final String tokenName;
  final String tokenSymbol;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: context.priceUpColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 64,
                    color: context.priceUpColor,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Token Launch Submitted!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your token "$tokenName ($tokenSymbol)" has been submitted for review.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You will receive a notification once your token is approved.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widgets
Widget _buildTextField(
  BuildContext context, {
  required String label,
  required String hint,
  required String value,
  required void Function(String) onChanged,
  TextInputType? keyboardType,
  int? maxLines,
  int? minLines,
  int? maxLength,
  String? prefix,
  String? suffix,
  TextCapitalization textCapitalization = TextCapitalization.none,
  String? Function(String?)? validator,
  String? errorText,
}) {
  final isDark = context.isDarkMode;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value.length),
        onChanged: (val) {
          onChanged(val);
          // Call validator for real-time validation
          if (validator != null) {
            validator(val);
          }
        },
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        minLines: minLines,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        style: TextStyle(
          color: context.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefix,
          suffixText: suffix,
          filled: true,
          fillColor: context.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: context.dividerColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: context.dividerColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: context.colors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: context.colors.error,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: context.colors.error,
              width: 2,
            ),
          ),
        ),
      ),
      if (errorText != null && errorText.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            errorText,
            style: TextStyle(
              color: context.colors.error,
              fontSize: 12,
            ),
          ),
        ),
    ],
  );
}

Widget _buildDropdown(
  BuildContext context, {
  required String label,
  required String value,
  required List<String> items,
  required void Function(String?) onChanged,
}) {
  final isDark = context.isDarkMode;

  return InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: context.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: context.dividerColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: context.dividerColor,
        ),
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isDense: true,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
        dropdownColor: context.cardBackground,
      ),
    ),
  );
}

Widget _buildDatePicker(
  BuildContext context, {
  required String label,
  required DateTime value,
  required void Function(DateTime) onChanged,
}) {
  final isDark = context.isDarkMode;

  return InkWell(
    onTap: () async {
      final date = await showDatePicker(
        context: context,
        initialDate: value,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: context.colors.primary,
                brightness: isDark ? Brightness.dark : Brightness.light,
              ),
            ),
            child: child!,
          );
        },
      );
      if (date != null) {
        onChanged(date);
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: context.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context.dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context.dividerColor,
          ),
        ),
        suffixIcon: Icon(
          Icons.calendar_today,
          color: context.textSecondary,
        ),
      ),
      child: Text(
        '${value.day}/${value.month}/${value.year}',
        style: TextStyle(
          color: context.textPrimary,
        ),
      ),
    ),
  );
}
