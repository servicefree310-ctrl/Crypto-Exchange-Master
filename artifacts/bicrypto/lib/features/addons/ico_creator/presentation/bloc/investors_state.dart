part of 'investors_cubit.dart';

abstract class InvestorsState extends Equatable {
  const InvestorsState();

  @override
  List<Object?> get props => [];
}

class InvestorsInitial extends InvestorsState {
  const InvestorsInitial();
}

class InvestorsLoading extends InvestorsState {
  const InvestorsLoading();
}

class InvestorsLoaded extends InvestorsState {
  const InvestorsLoaded(this.investors);

  final List<InvestorEntity> investors;

  @override
  List<Object?> get props => [investors];
}

class InvestorsError extends InvestorsState {
  const InvestorsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
