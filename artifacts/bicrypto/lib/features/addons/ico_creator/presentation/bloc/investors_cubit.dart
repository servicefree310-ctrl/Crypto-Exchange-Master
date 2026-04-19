import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/investor_entity.dart';
import '../../domain/usecases/get_investors_usecase.dart';

part 'investors_state.dart';

@injectable
class InvestorsCubit extends Cubit<InvestorsState> {
  InvestorsCubit(this._getInvestorsUseCase) : super(const InvestorsInitial());

  final GetInvestorsUseCase _getInvestorsUseCase;

  Future<void> fetchInvestors() async {
    emit(const InvestorsLoading());
    final result = await _getInvestorsUseCase();
    result.fold(
      (failure) => emit(InvestorsError(failure.message)),
      (investors) => emit(InvestorsLoaded(investors)),
    );
  }
}
