import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/p2p_payment_method_entity.dart';
import '../../domain/repositories/p2p_payment_methods_repository.dart';
import '../datasources/p2p_remote_datasource.dart';
import '../datasources/p2p_local_datasource.dart';

/// Repository implementation for P2P payment methods
@Injectable(as: P2PPaymentMethodsRepository)
class P2PPaymentMethodsRepositoryImpl implements P2PPaymentMethodsRepository {
  const P2PPaymentMethodsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  final P2PRemoteDataSource _remoteDataSource;
  final P2PLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<P2PPaymentMethodEntity>>> getPaymentMethods({
    bool includeCustom = false,
    bool onlyAvailable = true,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        // Try to get cached data
        final cachedData = await _localDataSource.getCachedPaymentMethods();
        if (cachedData != null && cachedData.isNotEmpty) {
          return Right(cachedData
              .map((json) => _convertV5ResponseToEntity(json))
              .toList());
        }
        return Left(NetworkFailure('No internet connection'));
      }

      final response = await _remoteDataSource.getPaymentMethods();

      // Cache the results
      await _localDataSource.cachePaymentMethods(response);

      // Convert V5 API response to P2PPaymentMethodEntity format
      final entities =
          response.map((v5Json) => _convertV5ResponseToEntity(v5Json)).toList();

      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, P2PPaymentMethodEntity>> createPaymentMethod({
    required String name,
    String? icon,
    String? description,
    String? instructions,
    String? processingTime,
    bool available = true,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final paymentMethodData = {
        'name': name,
        if (icon != null) 'icon': icon,
        if (description != null) 'description': description,
        if (instructions != null) 'instructions': instructions,
        if (processingTime != null) 'processingTime': processingTime,
        'available': available,
      };

      final response =
          await _remoteDataSource.createPaymentMethod(paymentMethodData);

      // Clear cache to refresh data
      await _localDataSource.clearPaymentMethodsCache();

      return Right(
        _convertV5ResponseToEntity(_extractPaymentMethodPayload(response)),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, P2PPaymentMethodEntity>> updatePaymentMethod({
    required String id,
    String? name,
    String? icon,
    String? description,
    String? instructions,
    String? processingTime,
    bool? available,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (icon != null) updateData['icon'] = icon;
      if (description != null) updateData['description'] = description;
      if (instructions != null) updateData['instructions'] = instructions;
      if (processingTime != null) updateData['processingTime'] = processingTime;
      if (available != null) updateData['available'] = available;

      final response =
          await _remoteDataSource.updatePaymentMethod(id, updateData);

      // Clear cache to refresh data
      await _localDataSource.clearPaymentMethodsCache();

      return Right(
        _convertV5ResponseToEntity(_extractPaymentMethodPayload(response)),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePaymentMethod({
    required String id,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      await _remoteDataSource.deletePaymentMethod(id);

      // Clear cache to refresh data
      await _localDataSource.clearPaymentMethodsCache();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Converts V5 API response format to P2PPaymentMethodEntity format
  /// V5 format: {id, name, icon, description, available, userId, instructions, processingTime, fees, popularityRank}
  /// Entity format: {id, name, type, currency, isEnabled, config}
  P2PPaymentMethodEntity _convertV5ResponseToEntity(
      Map<String, dynamic> v5Json) {
    final metadata = _asNullableMap(v5Json['metadata']);

    return P2PPaymentMethodEntity(
      id: v5Json['id']?.toString() ?? '',
      name: v5Json['name'] ?? '',
      type: (v5Json['type'] ?? 'payment_method').toString(),
      currency: (v5Json['currency'] ?? 'multi').toString(),
      isEnabled:
          _toBool(v5Json['isEnabled']) ?? _toBool(v5Json['available']) ?? true,
      config: {
        'icon': v5Json['icon'] ?? 'credit_card',
        'description': v5Json['description'] ?? '',
        'instructions': v5Json['instructions'],
        'processingTime': v5Json['processingTime'],
        'metadata': metadata,
        'fees': v5Json['fees'],
        'popularityRank': v5Json['popularityRank'] ?? 999,
        'isGlobal': _toBool(v5Json['isGlobal']) ?? false,
        'userId': v5Json['userId'], // For custom payment methods
        'isCustom': _toBool(v5Json['isCustom']) ?? (v5Json['userId'] != null),
      },
    );
  }

  Map<String, dynamic> _extractPaymentMethodPayload(
      Map<String, dynamic> response) {
    final nestedPaymentMethod = response['paymentMethod'];
    if (nestedPaymentMethod is Map<String, dynamic>) {
      return nestedPaymentMethod;
    }
    if (nestedPaymentMethod is Map) {
      return nestedPaymentMethod.cast<String, dynamic>();
    }

    final nestedData = response['data'];
    if (nestedData is Map<String, dynamic>) {
      return nestedData;
    }
    if (nestedData is Map) {
      return nestedData.cast<String, dynamic>();
    }

    return response;
  }

  Map<String, dynamic>? _asNullableMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return null;
  }

  bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }
}
