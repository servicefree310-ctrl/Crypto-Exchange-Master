import 'package:equatable/equatable.dart';

abstract class P2PMarketEvent extends Equatable {
  const P2PMarketEvent();
  @override
  List<Object?> get props => [];
}

class P2PMarketRequested extends P2PMarketEvent {
  const P2PMarketRequested({this.refresh = false});
  final bool refresh;
  @override
  List<Object?> get props => [refresh];
}

class P2PMarketRetryRequested extends P2PMarketEvent {
  const P2PMarketRetryRequested();
}
