import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'payment_methods_event.dart';
import 'payment_methods_state.dart';
import '../../../domain/usecases/get_payment_methods_usecase.dart';
import '../../../domain/usecases/payment_methods/create_payment_method_usecase.dart';
import '../../../domain/usecases/payment_methods/update_payment_method_usecase.dart';
import '../../../domain/usecases/payment_methods/delete_payment_method_usecase.dart';
import '../../../../../../../core/errors/failures.dart';
import '../../../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/payment_method_entity.dart';

@injectable
class PaymentMethodsBloc
    extends Bloc<PaymentMethodsEvent, PaymentMethodsState> {
  PaymentMethodsBloc(
    this._getMethods,
    this._createMethod,
    this._updateMethod,
    this._deleteMethod,
  ) : super(const PaymentMethodsInitial()) {
    on<PaymentMethodsRequested>(_onRequested);
    on<CreatePaymentMethodRequested>(_onCreate);
    on<UpdatePaymentMethodRequested>(_onUpdate);
    on<DeletePaymentMethodRequested>(_onDelete);
  }

  final GetPaymentMethodsUseCase _getMethods;
  final CreatePaymentMethodUseCase _createMethod;
  final UpdatePaymentMethodUseCase _updateMethod;
  final DeletePaymentMethodUseCase _deleteMethod;

  List<PaymentMethodEntity> _cache = [];

  Future<void> _onRequested(
    PaymentMethodsRequested event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    if (event.refresh && state is PaymentMethodsLoaded) {
      emit(const PaymentMethodsLoading(isRefresh: true));
    } else {
      emit(const PaymentMethodsLoading());
    }
    final result = await _getMethods(const NoParams());
    result.fold(
      (Failure failure) => emit(PaymentMethodsError(failure)),
      (methods) {
        _cache = methods;
        emit(PaymentMethodsLoaded(methods));
      },
    );
  }

  Future<void> _onCreate(
    CreatePaymentMethodRequested event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    emit(PaymentMethodsLoading(isRefresh: true));
    final params = CreatePaymentMethodParams(
      name: event.params['name'],
      icon: event.params['icon'],
      description: event.params['description'],
      instructions: event.params['instructions'],
      processingTime: event.params['processingTime'],
      available: event.params['available'] ?? true,
    );
    final result = await _createMethod(params);
    result.fold(
      (failure) => emit(PaymentMethodsError(failure)),
      (_) => add(const PaymentMethodsRequested(refresh: true)),
    );
  }

  Future<void> _onUpdate(
    UpdatePaymentMethodRequested event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    emit(PaymentMethodsLoading(isRefresh: true));
    final params = UpdatePaymentMethodParams(
      id: event.id,
      name: event.data['name'],
      icon: event.data['icon'],
      description: event.data['description'],
      instructions: event.data['instructions'],
      processingTime: event.data['processingTime'],
      available: event.data['available'],
    );
    final result = await _updateMethod(params);
    result.fold(
      (failure) => emit(PaymentMethodsError(failure)),
      (_) => add(const PaymentMethodsRequested(refresh: true)),
    );
  }

  Future<void> _onDelete(
    DeletePaymentMethodRequested event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    emit(PaymentMethodsLoading(isRefresh: true));
    final result = await _deleteMethod(DeletePaymentMethodParams(id: event.id));
    result.fold(
      (failure) => emit(PaymentMethodsError(failure)),
      (_) => add(const PaymentMethodsRequested(refresh: true)),
    );
  }
}
