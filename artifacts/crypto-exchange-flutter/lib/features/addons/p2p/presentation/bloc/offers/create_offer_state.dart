import 'package:equatable/equatable.dart';
import '../../../domain/entities/p2p_offer_entity.dart';
import '../../../../../../../core/errors/failures.dart';

/// V5-Compatible Wizard Steps (9 Steps Total)
enum CreateOfferStep {
  tradeType, // Step 1: Select BUY/SELL
  walletType, // Step 2: Select FIAT/SPOT/ECO
  selectCrypto, // Step 3: Choose cryptocurrency
  amountPrice, // Step 4: Set amount & price configuration
  paymentMethods, // Step 5: Select payment methods
  tradeSettings, // Step 6: Configure trade settings
  locationSettings, // Step 7: Set location and restrictions
  userRequirements, // Step 8: Set requirements for trading partners
  review, // Step 9: Review and submit
}

/// Helper extension for step management
extension CreateOfferStepExtension on CreateOfferStep {
  /// Get step number (1-based for UI display)
  int get stepNumber => index + 1;

  /// Check if this is the last step
  bool get isLastStep => this == CreateOfferStep.review;

  /// Get next step
  CreateOfferStep? get nextStep {
    if (index < CreateOfferStep.values.length - 1) {
      return CreateOfferStep.values[index + 1];
    }
    return null;
  }

  /// Get previous step
  CreateOfferStep? get previousStep {
    if (index > 0) {
      return CreateOfferStep.values[index - 1];
    }
    return null;
  }
}

/// Base state class
abstract class CreateOfferState extends Equatable {
  const CreateOfferState();
  @override
  List<Object?> get props => [];
}

class CreateOfferInitial extends CreateOfferState {
  const CreateOfferInitial();
}

class CreateOfferEditing extends CreateOfferState {
  const CreateOfferEditing({
    required this.step,
    required this.formData,
    this.validationErrors = const {},
    this.completedSteps = const {},
    this.isLoading = false,
    this.loadingSteps = const {},
  });

  final CreateOfferStep step;
  final Map<String, dynamic> formData;
  final Map<String, String> validationErrors;
  final Set<CreateOfferStep> completedSteps;
  final bool isLoading;
  final Set<CreateOfferStep> loadingSteps;

  @override
  List<Object?> get props => [
        step,
        formData,
        validationErrors,
        completedSteps,
        isLoading,
        loadingSteps
      ];

  CreateOfferEditing copyWith({
    CreateOfferStep? step,
    Map<String, dynamic>? formData,
    Map<String, String>? validationErrors,
    Set<CreateOfferStep>? completedSteps,
    bool? isLoading,
    Set<CreateOfferStep>? loadingSteps,
  }) {
    return CreateOfferEditing(
      step: step ?? this.step,
      formData: formData ?? this.formData,
      validationErrors: validationErrors ?? this.validationErrors,
      completedSteps: completedSteps ?? this.completedSteps,
      isLoading: isLoading ?? this.isLoading,
      loadingSteps: loadingSteps ?? this.loadingSteps,
    );
  }

  /// Helper methods for form data access
  String? get tradeType => formData['type'] as String?;
  String? get walletType => formData['walletType'] as String?;
  String? get currency => formData['currency'] as String?;
  Map<String, dynamic>? get amountConfig =>
      formData['amountConfig'] as Map<String, dynamic>?;
  Map<String, dynamic>? get priceConfig =>
      formData['priceConfig'] as Map<String, dynamic>?;
  Map<String, dynamic>? get tradeSettings =>
      formData['tradeSettings'] as Map<String, dynamic>?;
  Map<String, dynamic>? get locationSettings =>
      formData['locationSettings'] as Map<String, dynamic>?;
  Map<String, dynamic>? get userRequirements =>
      formData['userRequirements'] as Map<String, dynamic>?;
  List<String>? get paymentMethodIds =>
      (formData['paymentMethodIds'] as List<dynamic>?)?.cast<String>();

  /// Check if a step is completed
  bool isStepCompleted(CreateOfferStep step) => completedSteps.contains(step);

  /// Check if a step is loading
  bool isStepLoading(CreateOfferStep step) => loadingSteps.contains(step);

  /// Get progress percentage (0-100)
  double get progressPercentage =>
      (completedSteps.length / CreateOfferStep.values.length) * 100;
}

class CreateOfferSubmitting extends CreateOfferState {
  const CreateOfferSubmitting();
}

class CreateOfferSuccess extends CreateOfferState {
  const CreateOfferSuccess(this.offer);
  final P2POfferEntity offer;
  @override
  List<Object?> get props => [offer];
}

class CreateOfferFailure extends CreateOfferState {
  const CreateOfferFailure(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
