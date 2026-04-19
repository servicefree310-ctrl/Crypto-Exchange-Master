import 'dart:developer' as dev;

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/p2p_params.dart';
import '../../../domain/usecases/offers/create_offer_usecase.dart';
import '../../../domain/usecases/get_payment_methods_usecase.dart';
import '../../../domain/usecases/create_payment_method_usecase.dart';
import '../../../../../../core/network/dio_client.dart';
import '../../../../../../core/constants/api_constants.dart';
import '../../../../../../core/usecases/usecase.dart';

import '../../../../../../features/wallet/domain/usecases/get_wallet_balance_usecase.dart';
import 'create_offer_event.dart';
import 'create_offer_state.dart';

/// BLoC that powers the V5-compatible 9-step create-offer wizard
@injectable
class CreateOfferBloc extends Bloc<CreateOfferEvent, CreateOfferState> {
  CreateOfferBloc(
    this._createOfferUseCase,
    this._getPaymentMethodsUseCase,
    this._createPaymentMethodUseCase,
    this._getCurrencyWalletBalanceUseCase,
    this._dioClient,
  ) : super(const CreateOfferInitial()) {
    // Core wizard events
    on<CreateOfferStarted>(_onStarted);
    on<CreateOfferFieldUpdated>(_onFieldUpdated);
    on<CreateOfferSectionUpdated>(_onSectionUpdated);
    on<CreateOfferNextStep>(_onNextStep);
    on<CreateOfferPreviousStep>(_onPreviousStep);
    on<CreateOfferGoToStep>(_onGoToStep);
    on<CreateOfferStepCompleted>(_onStepCompleted);
    on<CreateOfferSubmitted>(_onSubmitted);
    on<CreateOfferReset>(_onReset);

    // Data fetching events
    on<CreateOfferFetchCurrencies>(_onFetchCurrencies);
    on<CreateOfferFetchWalletBalance>(_onFetchWalletBalance);
    on<CreateOfferFetchMarketPrice>(_onFetchMarketPrice);
    on<CreateOfferFetchPaymentMethods>(_onFetchPaymentMethods);
    on<CreateOfferFetchLocationData>(_onFetchLocationData);

    // Smart events for cascading data fetches
    on<CreateOfferWalletTypeSelected>(_onWalletTypeSelected);
    on<CreateOfferCurrencySelected>(_onCurrencySelected);
    on<CreateOfferTogglePaymentMethod>(_onTogglePaymentMethod);
    on<CreateOfferCalculatePrice>(_onCalculatePrice);
    on<CreateOfferValidateStep>(_onValidateStep);

    // Payment method events
    on<CreateOfferCreatePaymentMethod>(_onCreatePaymentMethod);
    on<CreateOfferUpdatePaymentMethods>(_onUpdatePaymentMethods);
  }

  final CreateOfferUseCase _createOfferUseCase;
  final GetPaymentMethodsUseCase _getPaymentMethodsUseCase;
  final CreatePaymentMethodUseCase _createPaymentMethodUseCase;
  final GetCurrencyWalletBalanceUseCase _getCurrencyWalletBalanceUseCase;
  final DioClient _dioClient;

  // Cache for fetched data
  final Map<String, List<Map<String, dynamic>>> _currenciesCache = {};
  List<dynamic> _paymentMethodsCache = [];
  final Map<String, dynamic> _marketPricesCache = {};
  final Map<String, double> _walletBalancesCache = {};

  // Internal helper to access the editing state safely
  CreateOfferEditing get _editingState => state is CreateOfferEditing
      ? state as CreateOfferEditing
      : const CreateOfferEditing(step: CreateOfferStep.tradeType, formData: {});

  void _onStarted(
    CreateOfferStarted event,
    Emitter<CreateOfferState> emit,
  ) {
    emit(const CreateOfferEditing(
      step: CreateOfferStep.tradeType,
      formData: {},
    ));
  }

  void _onFieldUpdated(
    CreateOfferFieldUpdated event,
    Emitter<CreateOfferState> emit,
  ) {
    final updatedData = Map<String, dynamic>.from(_editingState.formData)
      ..[event.field] = event.value;
    emit(_editingState.copyWith(formData: updatedData));
  }

  void _onSectionUpdated(
    CreateOfferSectionUpdated event,
    Emitter<CreateOfferState> emit,
  ) {
    final updatedData = Map<String, dynamic>.from(_editingState.formData)
      ..[event.section] = event.data;
    emit(_editingState.copyWith(formData: updatedData));
  }

  void _onNextStep(
    CreateOfferNextStep event,
    Emitter<CreateOfferState> emit,
  ) {
    final currentStep = _editingState.step;
    final nextStep = currentStep.nextStep;

    if (nextStep != null && _validateCurrentStep(currentStep)) {
      final completedSteps =
          Set<CreateOfferStep>.from(_editingState.completedSteps)
            ..add(currentStep);

      emit(_editingState.copyWith(
        step: nextStep,
        completedSteps: completedSteps,
      ));
    }
  }

  void _onPreviousStep(
    CreateOfferPreviousStep event,
    Emitter<CreateOfferState> emit,
  ) {
    final currentStep = _editingState.step;
    final previousStep = currentStep.previousStep;

    if (previousStep != null) {
      emit(_editingState.copyWith(step: previousStep));
    }
  }

  void _onGoToStep(
    CreateOfferGoToStep event,
    Emitter<CreateOfferState> emit,
  ) {
    if (event.step >= 0 && event.step < CreateOfferStep.values.length) {
      final targetStep = CreateOfferStep.values[event.step];
      emit(_editingState.copyWith(step: targetStep));
    }
  }

  void _onStepCompleted(
    CreateOfferStepCompleted event,
    Emitter<CreateOfferState> emit,
  ) {
    // This could be used for manual step completion marking
    // For now, we handle this automatically in _onNextStep
  }

  void _onReset(
    CreateOfferReset event,
    Emitter<CreateOfferState> emit,
  ) {
    // Clear all caches
    _currenciesCache.clear();
    _paymentMethodsCache.clear();
    _marketPricesCache.clear();
    _walletBalancesCache.clear();

    emit(const CreateOfferEditing(
      step: CreateOfferStep.tradeType,
      formData: {},
    ));
  }

  // ========================================
  // DATA FETCHING IMPLEMENTATIONS
  // ========================================

  Future<void> _onFetchCurrencies(
    CreateOfferFetchCurrencies event,
    Emitter<CreateOfferState> emit,
  ) async {
    if (_currenciesCache.containsKey(event.walletType)) {
      // Use cached data
      final updatedData = Map<String, dynamic>.from(_editingState.formData)
        ..['availableCurrencies'] = _currenciesCache[event.walletType];
      emit(_editingState.copyWith(formData: updatedData));
      return;
    }

    try {
      emit(_editingState.copyWith(isLoading: true));

      // Use V5's currency valid endpoint that returns currencies by wallet type
      final response = await _dioClient.get('/api/finance/currency/valid');

      if (response.statusCode == 200 && response.data != null) {
        final currenciesData = response.data as Map<String, dynamic>;

        // Map wallet type to correct currency data (like V5 does)
        String apiWalletType = event.walletType;
        if (event.walletType == 'ECO') {
          apiWalletType = 'FUNDING'; // ECO wallet uses FUNDING currencies in V5
        }

        final walletCurrencies =
            currenciesData[apiWalletType] as List<dynamic>? ?? [];

        // Convert to expected format for UI
        final currencyMaps = walletCurrencies
            .map<Map<String, dynamic>>((currency) => {
                  'currency':
                      currency['value'] ?? '', // symbol (e.g., 'BTC', 'ETH')
                  'name': currency['label'] ??
                      '', // display name (e.g., 'BTC - Bitcoin')
                  'network': currency['value'] ?? '', // use symbol as network
                  'icon': null, // V5 doesn't provide icons in this endpoint
                  'price': null, // will be fetched separately if needed
                  'status': true, // assume active
                })
            .toList();

        _currenciesCache[event.walletType] = currencyMaps;
        final updatedData = Map<String, dynamic>.from(_editingState.formData)
          ..['availableCurrencies'] = currencyMaps;

        emit(_editingState.copyWith(
          formData: updatedData,
          isLoading: false,
        ));
      } else {
        emit(_editingState.copyWith(
          isLoading: false,
          validationErrors: {'currencies': 'Failed to fetch currencies'},
        ));
      }
    } catch (e) {
      emit(_editingState.copyWith(
        isLoading: false,
        validationErrors: {
          'currencies': 'Failed to load currencies: ${e.toString()}'
        },
      ));
    }
  }

  Future<void> _onFetchWalletBalance(
    CreateOfferFetchWalletBalance event,
    Emitter<CreateOfferState> emit,
  ) async {
    final cacheKey = '${event.walletType}_${event.currency}';
    if (_walletBalancesCache.containsKey(cacheKey)) {
      final updatedData = Map<String, dynamic>.from(_editingState.formData)
        ..['walletBalance'] = _walletBalancesCache[cacheKey];
      emit(_editingState.copyWith(formData: updatedData));
      return;
    }

    try {
      emit(_editingState.copyWith(isLoading: true));

      final result = await _getCurrencyWalletBalanceUseCase(
        GetWalletBalanceParams(
          currency: event.currency,
          walletType: event.walletType,
        ),
      );

      result.fold(
        (failure) {
          emit(_editingState.copyWith(
            isLoading: false,
            validationErrors: {'balance': failure.message},
          ));
        },
        (balance) {
          _walletBalancesCache[cacheKey] = balance;
          final updatedData = Map<String, dynamic>.from(_editingState.formData)
            ..['walletBalance'] = balance;
          emit(_editingState.copyWith(
            formData: updatedData,
            isLoading: false,
          ));
        },
      );
    } catch (e) {
      emit(_editingState.copyWith(
        isLoading: false,
        validationErrors: {
          'balance': 'Failed to load balance: ${e.toString()}'
        },
      ));
    }
  }

  Future<void> _onFetchMarketPrice(
    CreateOfferFetchMarketPrice event,
    Emitter<CreateOfferState> emit,
  ) async {
    if (_marketPricesCache.containsKey(event.currency)) {
      final updatedData = Map<String, dynamic>.from(_editingState.formData)
        ..['marketPrice'] = _marketPricesCache[event.currency];
      emit(_editingState.copyWith(formData: updatedData));
      return;
    }

    try {
      emit(_editingState.copyWith(isLoading: true));

      // Fetch market price using ticker API
      final response = await _dioClient.get(
        '${ApiConstants.tickerSymbol}/${event.currency}/USDT',
      );

      if (response.statusCode == 200 && response.data != null) {
        final price = (response.data['price'] as num?)?.toDouble() ?? 0.0;
        _marketPricesCache[event.currency] = price;

        final updatedData = Map<String, dynamic>.from(_editingState.formData)
          ..['marketPrice'] = price;
        emit(_editingState.copyWith(
          formData: updatedData,
          isLoading: false,
        ));
      } else {
        emit(_editingState.copyWith(
          isLoading: false,
          validationErrors: {'price': 'Failed to fetch market price'},
        ));
      }
    } catch (e) {
      emit(_editingState.copyWith(
        isLoading: false,
        validationErrors: {'price': 'Failed to fetch price: ${e.toString()}'},
      ));
    }
  }

  Future<void> _onFetchPaymentMethods(
    CreateOfferFetchPaymentMethods event,
    Emitter<CreateOfferState> emit,
  ) async {
    if (_paymentMethodsCache.isNotEmpty) {
      final updatedData = Map<String, dynamic>.from(_editingState.formData)
        ..['availablePaymentMethods'] = _paymentMethodsCache;
      emit(_editingState.copyWith(formData: updatedData));
      return;
    }

    try {
      emit(_editingState.copyWith(isLoading: true));

      final result = await _getPaymentMethodsUseCase(const NoParams());

      result.fold(
        (failure) {
          emit(_editingState.copyWith(
            isLoading: false,
            validationErrors: {'paymentMethods': failure.message},
          ));
        },
        (paymentMethods) {
          // Convert PaymentMethodEntity list to Map format expected by UI
          final methodMaps = paymentMethods
              .map((method) => {
                    'id': method.id,
                    'name': method.name,
                    'icon': method.icon,
                    'description': method.description,
                    'available': method.available,
                    'isCustom': method.isCustom,
                    'userId': method.userId,
                    'instructions': method.instructions,
                    'processingTime': method.processingTime,
                    'fees': method.fees,
                    'popularityRank': method.popularityRank,
                  })
              .toList();

          _paymentMethodsCache = methodMaps;
          final updatedData = Map<String, dynamic>.from(_editingState.formData)
            ..['availablePaymentMethods'] = methodMaps;
          emit(_editingState.copyWith(
            formData: updatedData,
            isLoading: false,
          ));
        },
      );
    } catch (e) {
      emit(_editingState.copyWith(
        isLoading: false,
        validationErrors: {
          'paymentMethods': 'Failed to load payment methods: ${e.toString()}'
        },
      ));
    }
  }

  Future<void> _onFetchLocationData(
    CreateOfferFetchLocationData event,
    Emitter<CreateOfferState> emit,
  ) async {
    try {
      emit(_editingState.copyWith(isLoading: true));

      // Fetch location data from P2P locations API
      final response = await _dioClient.get(ApiConstants.p2pLocations);

      if (response.statusCode == 200 && response.data != null) {
        final updatedData = Map<String, dynamic>.from(_editingState.formData)
          ..['availableLocations'] = response.data;
        emit(_editingState.copyWith(
          formData: updatedData,
          isLoading: false,
        ));
      } else {
        emit(_editingState.copyWith(
          isLoading: false,
          validationErrors: {'locations': 'Failed to fetch location data'},
        ));
      }
    } catch (e) {
      emit(_editingState.copyWith(
        isLoading: false,
        validationErrors: {
          'locations': 'Failed to fetch locations: ${e.toString()}'
        },
      ));
    }
  }

  // ========================================
  // SMART EVENTS (CASCADING OPERATIONS)
  // ========================================

  Future<void> _onWalletTypeSelected(
    CreateOfferWalletTypeSelected event,
    Emitter<CreateOfferState> emit,
  ) async {
    // Update wallet type
    final updatedData = Map<String, dynamic>.from(_editingState.formData)
      ..['walletType'] = event.walletType;
    emit(_editingState.copyWith(formData: updatedData));

    // Automatically fetch currencies for this wallet type
    add(CreateOfferFetchCurrencies(walletType: event.walletType));
  }

  Future<void> _onCurrencySelected(
    CreateOfferCurrencySelected event,
    Emitter<CreateOfferState> emit,
  ) async {
    // Update currency
    final updatedData = Map<String, dynamic>.from(_editingState.formData)
      ..['currency'] = event.currency;
    emit(_editingState.copyWith(formData: updatedData));

    // Automatically fetch market price
    add(CreateOfferFetchMarketPrice(currency: event.currency));

    // If selling and wallet type is selected, fetch balance
    final walletType = _editingState.walletType;
    final tradeType = _editingState.tradeType;
    if (tradeType == 'SELL' && walletType != null) {
      add(CreateOfferFetchWalletBalance(
        currency: event.currency,
        walletType: walletType,
      ));
    }
  }

  void _onTogglePaymentMethod(
    CreateOfferTogglePaymentMethod event,
    Emitter<CreateOfferState> emit,
  ) {
    final currentMethods = List<String>.from(
      _editingState.paymentMethodIds ?? <String>[],
    );

    if (currentMethods.contains(event.paymentMethodId)) {
      currentMethods.remove(event.paymentMethodId);
    } else {
      currentMethods.add(event.paymentMethodId);
    }

    final updatedData = Map<String, dynamic>.from(_editingState.formData)
      ..['paymentMethodIds'] = currentMethods;
    emit(_editingState.copyWith(formData: updatedData));
  }

  void _onCalculatePrice(
    CreateOfferCalculatePrice event,
    Emitter<CreateOfferState> emit,
  ) {
    double finalPrice;

    if (event.model == 'FIXED') {
      finalPrice = event.value;
    } else {
      // MARGIN
      final marginPercent = event.value;
      finalPrice = event.marketPrice * (1 + (marginPercent / 100));
    }

    final currentPriceConfig = Map<String, dynamic>.from(
      _editingState.priceConfig ?? {},
    );
    currentPriceConfig.addAll({
      'model': event.model,
      'value': event.value,
      'marketPrice': event.marketPrice,
      'finalPrice': finalPrice,
    });

    final updatedData = Map<String, dynamic>.from(_editingState.formData)
      ..['priceConfig'] = currentPriceConfig;
    emit(_editingState.copyWith(formData: updatedData));
  }

  void _onValidateStep(
    CreateOfferValidateStep event,
    Emitter<CreateOfferState> emit,
  ) {
    if (event.stepIndex >= 0 &&
        event.stepIndex < CreateOfferStep.values.length) {
      final step = CreateOfferStep.values[event.stepIndex];
      final isValid = _validateCurrentStep(step);

      if (isValid) {
        final completedSteps =
            Set<CreateOfferStep>.from(_editingState.completedSteps)..add(step);
        emit(_editingState.copyWith(completedSteps: completedSteps));
      }
    }
  }

  // ========================================
  // SUBMISSION LOGIC
  // ========================================

  Future<void> _onSubmitted(
    CreateOfferSubmitted event,
    Emitter<CreateOfferState> emit,
  ) async {
    dev.log('🚀 CREATE OFFER SUBMISSION STARTED');
    dev.log('📊 Current form data: ${_editingState.formData}');

    // Final validation of all steps
    final errors = <String, String>{};
    final data = _editingState.formData;

    dev.log('🔍 VALIDATION PHASE');
    // Validate required fields according to v5 backend schema
    if (data['type'] == null || data['type'].toString().isEmpty) {
      errors['type'] = 'Trade type is required';
      dev.log('❌ Trade type validation failed');
    } else {
      dev.log('✅ Trade type: ${data['type']}');
    }

    if (data['currency'] == null || data['currency'].toString().isEmpty) {
      errors['currency'] = 'Currency is required';
      dev.log('❌ Currency validation failed');
    } else {
      dev.log('✅ Currency: ${data['currency']}');
    }

    if (data['walletType'] == null || data['walletType'].toString().isEmpty) {
      errors['walletType'] = 'Wallet type is required';
      dev.log('❌ Wallet type validation failed');
    } else {
      dev.log('✅ Wallet type: ${data['walletType']}');
    }

    final amountConfig = data['amountConfig'] as Map<String, dynamic>?;
    if (amountConfig == null || amountConfig['total'] == null) {
      errors['amount'] = 'Amount configuration is required';
      dev.log('❌ Amount config validation failed');
    } else {
      dev.log('✅ Amount config: $amountConfig');
    }

    final priceConfig = data['priceConfig'] as Map<String, dynamic>?;
    if (priceConfig == null || priceConfig['finalPrice'] == null) {
      errors['price'] = 'Price configuration is required';
      dev.log('❌ Price config validation failed');
    } else {
      dev.log('✅ Price config: $priceConfig');
    }

    final tradeSettings = data['tradeSettings'] as Map<String, dynamic>?;
    if (tradeSettings == null ||
        tradeSettings['termsOfTrade'] == null ||
        tradeSettings['termsOfTrade'].toString().trim().isEmpty) {
      errors['terms'] = 'Terms of trade are required';
      dev.log('❌ Trade settings validation failed');
    } else {
      dev.log('✅ Trade settings: $tradeSettings');
    }

    final locationSettings = data['locationSettings'] as Map<String, dynamic>?;
    if (locationSettings == null ||
        locationSettings['country'] == null ||
        locationSettings['country'].toString().trim().isEmpty) {
      errors['location'] = 'Country is required';
      dev.log('❌ Location settings validation failed');
    } else {
      dev.log('✅ Location settings: $locationSettings');
    }

    final paymentMethodIds = data['paymentMethodIds'] as List<String>?;
    if (paymentMethodIds == null || paymentMethodIds.isEmpty) {
      errors['paymentMethods'] = 'At least one payment method is required';
      dev.log('❌ Payment methods validation failed');
    } else {
      dev.log('✅ Payment methods: $paymentMethodIds');
    }

    if (errors.isNotEmpty) {
      dev.log('💥 VALIDATION ERRORS: $errors');
      emit(_editingState.copyWith(validationErrors: errors));
      return;
    }

    dev.log('✅ ALL VALIDATIONS PASSED');
    emit(const CreateOfferSubmitting());

    // Build CreateOfferParams using the exact v5 schema
    final params = CreateOfferParams(
      type: data['type'],
      currency: data['currency'],
      walletType: data['walletType'],
      amountConfig: amountConfig!,
      priceConfig: priceConfig!,
      tradeSettings: tradeSettings!,
      locationSettings: locationSettings,
      userRequirements: data['userRequirements'] as Map<String, dynamic>?,
      paymentMethodIds: paymentMethodIds,
    );

    dev.log('📦 PARAMS CREATED FOR USE CASE:');
    dev.log('  Type: ${params.type}');
    dev.log('  Currency: ${params.currency}');
    dev.log('  Wallet Type: ${params.walletType}');
    dev.log('  Amount Config: ${params.amountConfig}');
    dev.log('  Price Config: ${params.priceConfig}');
    dev.log('  Trade Settings: ${params.tradeSettings}');
    dev.log('  Location Settings: ${params.locationSettings}');
    dev.log('  User Requirements: ${params.userRequirements}');
    dev.log('  Payment Method IDs: ${params.paymentMethodIds}');

    dev.log('🔄 CALLING USE CASE...');
    final result = await _createOfferUseCase(params);

    result.fold(
      (failure) {
        dev.log('💥 USE CASE FAILED: ${failure.message}');
        emit(CreateOfferFailure(failure));
      },
      (offer) {
        dev.log('🎉 USE CASE SUCCESS: ${offer.id}');
        emit(CreateOfferSuccess(offer));
      },
    );
  }

  // ========================================
  // PAYMENT METHOD OPERATIONS
  // ========================================

  Future<void> _onCreatePaymentMethod(
    CreateOfferCreatePaymentMethod event,
    Emitter<CreateOfferState> emit,
  ) async {
    try {
      emit(_editingState.copyWith(isLoading: true));

      final result = await _createPaymentMethodUseCase(
        CreatePaymentMethodParams(
          name: event.name,
          icon: event.icon,
          description: event.description,
          instructions: event.instructions,
          processingTime: event.processingTime,
          available: event.available,
        ),
      );

      result.fold(
        (failure) {
          emit(_editingState.copyWith(
            isLoading: false,
            validationErrors: {'createPaymentMethod': failure.message},
          ));
        },
        (paymentMethod) {
          // Add the new payment method to cache and select it
          final updatedMethods = List<dynamic>.from(_paymentMethodsCache)
            ..add({
              'id': paymentMethod.id,
              'name': paymentMethod.name,
              'icon': paymentMethod.icon,
              'description': paymentMethod.description,
              'available': paymentMethod.available,
              'isCustom': paymentMethod.isCustom,
              'userId': paymentMethod.userId,
              'instructions': paymentMethod.instructions,
              'processingTime': paymentMethod.processingTime,
              'fees': paymentMethod.fees,
            });

          _paymentMethodsCache = updatedMethods;

          // Auto-select the newly created payment method
          final currentMethods = List<String>.from(
            _editingState.paymentMethodIds ?? <String>[],
          );
          currentMethods.add(paymentMethod.id);

          final updatedData = Map<String, dynamic>.from(_editingState.formData)
            ..['availablePaymentMethods'] = updatedMethods
            ..['paymentMethodIds'] = currentMethods;

          emit(_editingState.copyWith(
            formData: updatedData,
            isLoading: false,
            validationErrors: {}, // Clear any previous errors
          ));
        },
      );
    } catch (e) {
      emit(_editingState.copyWith(
        isLoading: false,
        validationErrors: {
          'createPaymentMethod':
              'Failed to create payment method: ${e.toString()}'
        },
      ));
    }
  }

  void _onUpdatePaymentMethods(
    CreateOfferUpdatePaymentMethods event,
    Emitter<CreateOfferState> emit,
  ) {
    final updatedData = Map<String, dynamic>.from(_editingState.formData)
      ..['paymentMethodIds'] = event.selectedMethodIds;
    emit(_editingState.copyWith(formData: updatedData));
  }

  // ========================================
  // VALIDATION LOGIC
  // ========================================

  bool _validateCurrentStep(CreateOfferStep step) {
    final data = _editingState.formData;

    switch (step) {
      case CreateOfferStep.tradeType:
        return data['type'] != null && ['BUY', 'SELL'].contains(data['type']);

      case CreateOfferStep.walletType:
        return data['walletType'] != null &&
            ['FIAT', 'SPOT', 'ECO'].contains(data['walletType']);

      case CreateOfferStep.selectCrypto:
        return data['currency'] != null &&
            data['currency'].toString().isNotEmpty;

      case CreateOfferStep.amountPrice:
        final amountConfig = data['amountConfig'] as Map<String, dynamic>?;
        final priceConfig = data['priceConfig'] as Map<String, dynamic>?;
        return amountConfig != null &&
            amountConfig['total'] != null &&
            (amountConfig['total'] as num) > 0 &&
            priceConfig != null &&
            priceConfig['finalPrice'] != null &&
            (priceConfig['finalPrice'] as num) > 0;

      case CreateOfferStep.paymentMethods:
        final methods = data['paymentMethodIds'] as List<String>?;
        return methods != null && methods.isNotEmpty;

      case CreateOfferStep.tradeSettings:
        final settings = data['tradeSettings'] as Map<String, dynamic>?;
        return settings != null &&
            settings['termsOfTrade'] != null &&
            settings['termsOfTrade'].toString().trim().isNotEmpty;

      case CreateOfferStep.locationSettings:
        final location = data['locationSettings'] as Map<String, dynamic>?;
        return location != null &&
            location['country'] != null &&
            location['country'].toString().trim().isNotEmpty;

      case CreateOfferStep.userRequirements:
        // Optional step - always valid
        return true;

      case CreateOfferStep.review:
        // Final review step - validate all required data is present
        return _validateAllSteps();
    }
  }

  bool _validateAllSteps() {
    // Check all required steps are completed
    for (final step in CreateOfferStep.values) {
      if (step == CreateOfferStep.review) continue; // Skip review step itself
      if (step == CreateOfferStep.userRequirements) continue; // Optional step

      if (!_validateCurrentStep(step)) {
        return false;
      }
    }
    return true;
  }
}
