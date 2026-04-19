// Offer Detail States
import 'package:equatable/equatable.dart';
import '../../../domain/entities/p2p_offer_entity.dart';
import '../../../../../../../core/errors/failures.dart';

abstract class OfferDetailState extends Equatable {
  const OfferDetailState();
  @override
  List<Object?> get props => [];
}

class OfferDetailInitial extends OfferDetailState {
  const OfferDetailInitial();
}

class OfferDetailLoading extends OfferDetailState {
  const OfferDetailLoading(this.offerId, {this.isRefresh = false});
  final String offerId;
  final bool isRefresh;
  @override
  List<Object?> get props => [offerId, isRefresh];
}

class OfferDetailLoaded extends OfferDetailState {
  const OfferDetailLoaded(this.offer);
  final P2POfferEntity offer;
  @override
  List<Object?> get props => [offer];
}

class OfferDetailError extends OfferDetailState {
  const OfferDetailError(this.failure, this.offerId);
  final Failure failure;
  final String offerId;
  @override
  List<Object?> get props => [failure, offerId];
}
