import 'package:equatable/equatable.dart';

import '../../../domain/usecases/trades/get_trades_usecase.dart';
import '../../../../../../../core/errors/failures.dart';

abstract class TradesState extends Equatable {
  const TradesState();
  @override
  List<Object?> get props => [];
}

class TradesInitial extends TradesState {
  const TradesInitial();
}

class TradesLoading extends TradesState {
  const TradesLoading({this.isRefresh = false});
  final bool isRefresh;
  @override
  List<Object?> get props => [isRefresh];
}

class TradesLoaded extends TradesState {
  const TradesLoaded(this.response, {this.canLoadMore = false});
  final P2PTradesResponse response;
  final bool canLoadMore;
  @override
  List<Object?> get props => [response, canLoadMore];
}

class TradesError extends TradesState {
  const TradesError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
