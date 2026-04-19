import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import '../entities/p2p_offer_entity.dart';
import '../entities/p2p_offers_response.dart';
import '../entities/p2p_params.dart';

// Parameter types are imported from shared p2p_params.dart

abstract class P2POffersRepository {
  /// Get paginated list of offers with filtering and sorting
  /// Based on: GET /api/ext/p2p/offer
  Future<Either<Failure, P2POffersResponse>> getOffers(GetOffersParams params);

  /// Create a new P2P offer
  /// Based on: POST /api/ext/p2p/offer
  Future<Either<Failure, P2POfferEntity>> createOffer(CreateOfferParams params);

  /// Get offer by ID with seller metrics
  /// Based on: GET /api/ext/p2p/offer/{id}
  Future<Either<Failure, P2POfferEntity>> getOfferById(String offerId);

  /// Get popular offers by trade count and ratings
  /// Based on: GET /api/ext/p2p/offer/popularity
  Future<Either<Failure, List<P2POfferEntity>>> getPopularOffers(
      {int limit = 10});

  /// Update an existing offer
  /// Based on: PUT /api/ext/p2p/offer/{id}
  Future<Either<Failure, P2POfferEntity>> updateOffer(
      String offerId, CreateOfferParams params);

  /// Delete/deactivate an offer
  /// Based on: DELETE /api/ext/p2p/offer/{id}
  Future<Either<Failure, void>> deleteOffer(String offerId);

  /// Get user's own offers
  Future<Either<Failure, P2POffersResponse>> getUserOffers(
      GetOffersParams params);

  /// Toggle offer status (activate/deactivate)
  Future<Either<Failure, P2POfferEntity>> toggleOfferStatus(String offerId);

  /// Flag an offer for review
  Future<Either<Failure, void>> flagOffer(String offerId, String reason);

  /// Get offers matching specific criteria for guided matching
  Future<Either<Failure, List<P2POfferEntity>>> getMatchingOffers(
      Map<String, dynamic> criteria);

  // Popular and featured offers
  Future<Either<Failure, List<P2POfferEntity>>> getFeaturedOffers({
    int limit = 5,
  });

  // Offer interactions
  Future<Either<Failure, void>> favoriteOffer(String offerId);
  Future<Either<Failure, void>> unfavoriteOffer(String offerId);
  Future<Either<Failure, List<P2POfferEntity>>> getFavoriteOffers();

  // Offer statistics
  Future<Either<Failure, Map<String, dynamic>>> getOfferStats(String offerId);

  // Real-time offers stream (for WebSocket updates)
  Stream<Either<Failure, List<P2POfferEntity>>> watchOffers(
      GetOffersParams params);
  Stream<Either<Failure, P2POfferEntity>> watchOffer(String offerId);

  // Cache management
  Future<Either<Failure, void>> clearOffersCache();
  Future<Either<Failure, void>> refreshOffers(GetOffersParams params);
}
