import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/repositories/p2p_matching_repository.dart';
import '../../domain/usecases/matching/guided_matching_usecase.dart';
import '../../domain/usecases/matching/compare_prices_usecase.dart';
import '../datasources/p2p_remote_datasource.dart';
import '../datasources/p2p_local_datasource.dart';

/// Repository implementation for P2P matching operations
@Injectable(as: P2PMatchingRepository)
class P2PMatchingRepositoryImpl implements P2PMatchingRepository {
  const P2PMatchingRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  final P2PRemoteDataSource _remoteDataSource;
  final P2PLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, GuidedMatchingResponse>> findMatches({
    required String tradeType,
    required String cryptocurrency,
    required double amount,
    required List<String> paymentMethods,
    required String pricePreference,
    required String traderPreference,
    required String location,
    int maxResults = 30,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final criteria = {
        'tradeType': tradeType,
        'cryptocurrency': cryptocurrency,
        'amount': amount,
        'paymentMethods': paymentMethods,
        'pricePreference': pricePreference,
        'traderPreference': traderPreference,
        'location': location,
        'maxResults': maxResults,
      };

      final response = await _remoteDataSource.findMatches(criteria);

      return Right(_convertJsonToGuidedMatchingResponse(response));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PriceComparisonResponse>> comparePrices({
    required String cryptocurrency,
    required String tradeType,
    required double amount,
    required double p2pPrice,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final criteria = {
        'cryptocurrency': cryptocurrency,
        'tradeType': tradeType,
        'amount': amount,
        'p2pPrice': p2pPrice,
      };

      final response = await _remoteDataSource.comparePrices(criteria);

      return Right(_convertJsonToPriceComparisonResponse(response));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // Helper methods
  GuidedMatchingResponse _convertJsonToGuidedMatchingResponse(
      Map<String, dynamic> json) {
    final matches = json['matches'] as List? ?? [];
    final marketData = json['marketData'] as Map<String, dynamic>? ?? {};
    final recommendations = json['recommendations'] as List? ?? [];

    final searchCriteria = GuidedMatchingParams(
      tradeType: json['searchCriteria']?['tradeType']?.toString() ?? '',
      cryptocurrency:
          json['searchCriteria']?['cryptocurrency']?.toString() ?? '',
      amount: (json['searchCriteria']?['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethods: (json['searchCriteria']?['paymentMethods'] as List?)
              ?.cast<String>() ??
          [],
      pricePreference:
          json['searchCriteria']?['pricePreference']?.toString() ?? '',
      traderPreference:
          json['searchCriteria']?['traderPreference']?.toString() ?? '',
      location: json['searchCriteria']?['location']?.toString() ?? '',
      maxResults: json['searchCriteria']?['maxResults'] as int? ?? 30,
    );

    return GuidedMatchingResponse(
      matches: matches
          .map((match) => MatchedOffer(
                id: match['offerId']?.toString() ?? '',
                type: match['type']?.toString() ?? '',
                coin: match['cryptocurrency']?.toString() ?? '',
                walletType: match['walletType']?.toString() ?? '',
                price: (match['price'] as num?)?.toDouble() ?? 0.0,
                minLimit: (match['minLimit'] as num?)?.toDouble() ?? 0.0,
                maxLimit: (match['maxLimit'] as num?)?.toDouble() ?? 0.0,
                availableAmount:
                    (match['availableAmount'] as num?)?.toDouble() ?? 0.0,
                paymentMethods:
                    (match['paymentMethods'] as List?)?.cast<String>() ?? [],
                matchScore: match['matchScore'] as int? ?? 0,
                trader: TraderInfo(
                  id: match['trader']?['id']?.toString() ?? '',
                  name: match['trader']?['name']?.toString() ?? '',
                  avatar: match['trader']?['avatar']?.toString(),
                  completedTrades:
                      match['trader']?['completedTrades'] as int? ?? 0,
                  completionRate:
                      match['trader']?['completionRate'] as int? ?? 0,
                  verified: match['trader']?['verified'] as bool? ?? false,
                  responseTime: match['trader']?['responseTime'] as int? ?? 0,
                  avgRating:
                      (match['trader']?['avgRating'] as num?)?.toDouble() ??
                          0.0,
                ),
                benefits: (match['benefits'] as List?)?.cast<String>() ?? [],
                location: match['location']?.toString() ?? '',
                createdAt:
                    DateTime.tryParse(match['createdAt']?.toString() ?? '') ??
                        DateTime.now(),
                updatedAt:
                    DateTime.tryParse(match['updatedAt']?.toString() ?? '') ??
                        DateTime.now(),
              ))
          .toList(),
      matchCount: json['totalMatches'] as int? ?? matches.length,
      estimatedSavings: (json['estimatedSavings'] as num?)?.toDouble() ?? 0.0,
      bestPrice: (json['bestPrice'] as num?)?.toDouble() ?? 0.0,
      marketPrice: (json['marketPrice'] as num?)?.toDouble() ?? 0.0,
      searchCriteria: searchCriteria,
    );
  }

  PriceComparisonResponse _convertJsonToPriceComparisonResponse(
      Map<String, dynamic> json) {
    return PriceComparisonResponse(
      marketPrice: (json['marketPrice'] as num?)?.toDouble() ?? 0.0,
      p2pPrice: (json['p2pPrice'] as num?)?.toDouble() ?? 0.0,
      difference: (json['difference'] as num?)?.toDouble() ?? 0.0,
      percentageDifference:
          (json['percentageDifference'] as num?)?.toDouble() ?? 0.0,
      estimatedSavings: (json['estimatedSavings'] as num?)?.toDouble() ?? 0.0,
      isPremium: json['isPremium'] as bool? ?? false,
      recommendation: json['recommendation']?.toString() ?? '',
      priceInsights: (json['priceInsights'] as List?)?.cast<String>() ?? [],
    );
  }
}
