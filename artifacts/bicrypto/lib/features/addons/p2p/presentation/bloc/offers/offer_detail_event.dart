import 'package:equatable/equatable.dart';

abstract class OfferDetailEvent extends Equatable {
  const OfferDetailEvent();
  @override
  List<Object?> get props => [];
}

class OfferDetailRequested extends OfferDetailEvent {
  const OfferDetailRequested(this.offerId, {this.refresh = false});
  final String offerId;
  final bool refresh;
  @override
  List<Object?> get props => [offerId, refresh];
}

class OfferDetailRetryRequested extends OfferDetailEvent {
  const OfferDetailRetryRequested();
}
