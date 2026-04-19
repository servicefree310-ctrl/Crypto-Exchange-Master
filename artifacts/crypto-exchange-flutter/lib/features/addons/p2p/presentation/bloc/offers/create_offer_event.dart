import 'package:equatable/equatable.dart';

/// Base class for create offer events
abstract class CreateOfferEvent extends Equatable {
  const CreateOfferEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start the offer creation wizard
class CreateOfferStarted extends CreateOfferEvent {
  const CreateOfferStarted();
}

/// Event to update a specific field in the form
class CreateOfferFieldUpdated extends CreateOfferEvent {
  const CreateOfferFieldUpdated({
    required this.field,
    required this.value,
  });

  final String field;
  final dynamic value;

  @override
  List<Object?> get props => [field, value];
}

/// Event to update complex form sections (like amountConfig, priceConfig)
class CreateOfferSectionUpdated extends CreateOfferEvent {
  const CreateOfferSectionUpdated({
    required this.section,
    required this.data,
  });

  final String section; // 'amountConfig', 'priceConfig', 'tradeSettings', etc.
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [section, data];
}

/// Event to move to the next step
class CreateOfferNextStep extends CreateOfferEvent {
  const CreateOfferNextStep();
}

/// Event to move to the previous step
class CreateOfferPreviousStep extends CreateOfferEvent {
  const CreateOfferPreviousStep();
}

/// Event to go to a specific step
class CreateOfferGoToStep extends CreateOfferEvent {
  const CreateOfferGoToStep(this.step);

  final int step; // 0-based index

  @override
  List<Object?> get props => [step];
}

/// Event to mark a step as completed
class CreateOfferStepCompleted extends CreateOfferEvent {
  const CreateOfferStepCompleted(this.step);

  final String step; // step name

  @override
  List<Object?> get props => [step];
}

/// Event to submit the complete offer
class CreateOfferSubmitted extends CreateOfferEvent {
  const CreateOfferSubmitted();
}

/// Event to reset the form
class CreateOfferReset extends CreateOfferEvent {
  const CreateOfferReset();
}

// ========================================
// DATA FETCHING EVENTS (V5-Compatible)
// ========================================

/// Event to fetch available currencies for selected wallet type
class CreateOfferFetchCurrencies extends CreateOfferEvent {
  const CreateOfferFetchCurrencies({required this.walletType});

  final String walletType; // FIAT, SPOT, ECO

  @override
  List<Object?> get props => [walletType];
}

/// Event to fetch user's wallet balance for selected currency
class CreateOfferFetchWalletBalance extends CreateOfferEvent {
  const CreateOfferFetchWalletBalance({
    required this.currency,
    required this.walletType,
  });

  final String currency;
  final String walletType;

  @override
  List<Object?> get props => [currency, walletType];
}

/// Event to fetch current market price for selected currency
class CreateOfferFetchMarketPrice extends CreateOfferEvent {
  const CreateOfferFetchMarketPrice({required this.currency});

  final String currency;

  @override
  List<Object?> get props => [currency];
}

/// Event to fetch available payment methods
class CreateOfferFetchPaymentMethods extends CreateOfferEvent {
  const CreateOfferFetchPaymentMethods();
}

/// Event to fetch location/country data
class CreateOfferFetchLocationData extends CreateOfferEvent {
  const CreateOfferFetchLocationData();
}

/// Event to validate step data before proceeding
class CreateOfferValidateStep extends CreateOfferEvent {
  const CreateOfferValidateStep(this.stepIndex);

  final int stepIndex;

  @override
  List<Object?> get props => [stepIndex];
}

/// Event to calculate price based on margin/fixed model
class CreateOfferCalculatePrice extends CreateOfferEvent {
  const CreateOfferCalculatePrice({
    required this.model,
    required this.value,
    required this.marketPrice,
  });

  final String model; // FIXED or MARGIN
  final double value;
  final double marketPrice;

  @override
  List<Object?> get props => [model, value, marketPrice];
}

/// Event to add/remove payment method
class CreateOfferTogglePaymentMethod extends CreateOfferEvent {
  const CreateOfferTogglePaymentMethod({required this.paymentMethodId});

  final String paymentMethodId;

  @override
  List<Object?> get props => [paymentMethodId];
}

/// Event to set wallet type and fetch related data
class CreateOfferWalletTypeSelected extends CreateOfferEvent {
  const CreateOfferWalletTypeSelected({required this.walletType});

  final String walletType;

  @override
  List<Object?> get props => [walletType];
}

/// Event to set currency and fetch related data (price, balance)
class CreateOfferCurrencySelected extends CreateOfferEvent {
  const CreateOfferCurrencySelected({required this.currency});

  final String currency;

  @override
  List<Object?> get props => [currency];
}

/// Event to create a custom payment method
class CreateOfferCreatePaymentMethod extends CreateOfferEvent {
  const CreateOfferCreatePaymentMethod({
    required this.name,
    this.icon,
    this.description,
    this.instructions,
    this.processingTime,
    this.available = true,
  });

  final String name;
  final String? icon;
  final String? description;
  final String? instructions;
  final String? processingTime;
  final bool available;

  @override
  List<Object?> get props => [
        name,
        icon,
        description,
        instructions,
        processingTime,
        available,
      ];
}

/// Event to update payment methods selection
class CreateOfferUpdatePaymentMethods extends CreateOfferEvent {
  const CreateOfferUpdatePaymentMethods({required this.selectedMethodIds});

  final List<String> selectedMethodIds;

  @override
  List<Object?> get props => [selectedMethodIds];
}
