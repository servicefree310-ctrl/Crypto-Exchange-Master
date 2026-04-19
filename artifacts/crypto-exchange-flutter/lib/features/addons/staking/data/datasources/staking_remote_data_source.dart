import 'dart:developer' as dev;

import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/errors/exceptions.dart';
import 'package:mobile/core/constants/api_constants.dart';
import '../models/staking_pool_model.dart';
import '../models/staking_position_model.dart';
import '../models/staking_stats_model.dart';
import '../models/pool_analytics_model.dart';

@injectable
class StakingRemoteDataSource {
  final DioClient _client;
  const StakingRemoteDataSource(this._client);

  /// Fetch all staking pools
  Future<List<StakingPoolModel>> getPools({
    String? status,
    double? minApr,
    double? maxApr,
    String? token,
  }) async {
    dev.log(
        '🏊 STAKING_REMOTE_DS: getPools() called - status=$status, minApr=$minApr, maxApr=$maxApr, token=$token');
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (minApr != null) queryParams['minApr'] = minApr.toString();
      if (maxApr != null) queryParams['maxApr'] = maxApr.toString();
      if (token != null) queryParams['token'] = token;

      final response = await _client.get(
        ApiConstants.stakingPools,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        dev.log('🏊 STAKING_REMOTE_DS: getPools() success');
        dev.log(
            '🏊 STAKING_REMOTE_DS: Response data type: ${response.data.runtimeType}');

        // Handle both direct array and wrapped response
        final dynamic responseData = response.data;
        final List dataList;

        if (responseData is List) {
          // Direct array response
          dataList = responseData;
        } else if (responseData is Map) {
          final responseMap = Map<String, dynamic>.from(responseData);
          // Wrapped response (e.g., {data: [...]} or direct map for single item)
          if (responseMap.containsKey('data')) {
            final data = responseMap['data'];
            if (data is List) {
              dataList = data;
            } else {
              // Single item wrapped in data
              dataList = [data];
            }
          } else if (responseMap['pools'] is List) {
            dataList = responseMap['pools'] as List;
          } else {
            // Response is a single object
            dataList = [responseMap];
          }
        } else {
          dev.log('🔴 STAKING_REMOTE_DS: Unexpected response type');
          dataList = [];
        }

        dev.log('🏊 STAKING_REMOTE_DS: Parsing ${dataList.length} pools');
        final pools = <StakingPoolModel>[];
        for (var i = 0; i < dataList.length; i++) {
          try {
            final item = dataList[i];
            if (item is! Map) {
              throw const FormatException('Pool item is not a map');
            }
            final pool = StakingPoolModel.fromJson(
              Map<String, dynamic>.from(item),
            );
            pools.add(pool);
          } catch (e) {
            dev.log('🔴 STAKING_REMOTE_DS: Error parsing pool at index $i: $e');
            dev.log('🔴 STAKING_REMOTE_DS: Pool data: ${dataList[i]}');
            // Continue parsing other pools
          }
        }
        dev.log(
            '🏊 STAKING_REMOTE_DS: Successfully parsed ${pools.length} of ${dataList.length} pools');
        return pools;
      } else {
        throw ServerException(
            'Failed to fetch staking pools: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log('🏊 STAKING_REMOTE_DS: getPools() DioException: ${e.type}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const TimeoutException('Connection timeout');
      }
      throw NetworkException(e.message ?? 'Network error');
    } catch (e) {
      dev.log('🏊 STAKING_REMOTE_DS: getPools() Exception: $e');
      throw ServerException(e.toString());
    }
  }

  /// Fetch user's staking positions
  Future<List<StakingPositionModel>> getUserPositions({
    String? poolId,
    String? status,
  }) async {
    dev.log(
        '👤 STAKING_REMOTE_DS: getUserPositions() called - poolId=$poolId, status=$status');
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;
      if (poolId != null) params['poolId'] = poolId;

      final response = await _client.get(
        ApiConstants.stakingPositions,
        queryParameters: params,
      );
      if (response.statusCode == 200) {
        dev.log('👤 STAKING_REMOTE_DS: getUserPositions() success');
        dev.log(
            '👤 STAKING_REMOTE_DS: Response data type: ${response.data.runtimeType}');

        // Handle both direct array and wrapped response
        final dynamic responseData = response.data;
        final List dataList;

        if (responseData is List) {
          // Direct array response
          dataList = responseData;
        } else if (responseData is Map) {
          final responseMap = Map<String, dynamic>.from(responseData);
          // Wrapped response (e.g., {data: [...]} or direct map for single item)
          if (responseMap.containsKey('data')) {
            final data = responseMap['data'];
            if (data is List) {
              dataList = data;
            } else {
              // Single item wrapped in data
              dataList = [data];
            }
          } else if (responseMap['positions'] is List) {
            dataList = responseMap['positions'] as List;
          } else {
            // Response is a single object
            dataList = [responseMap];
          }
        } else {
          dev.log('🔴 STAKING_REMOTE_DS: Unexpected response type');
          dataList = [];
        }

        dev.log('👤 STAKING_REMOTE_DS: Parsing ${dataList.length} positions');
        final positions = <StakingPositionModel>[];
        for (var i = 0; i < dataList.length; i++) {
          try {
            final item = dataList[i];
            if (item is! Map) {
              throw const FormatException('Position item is not a map');
            }
            final position = StakingPositionModel.fromJson(
              Map<String, dynamic>.from(item),
            );
            positions.add(position);
          } catch (e) {
            dev.log(
                '🔴 STAKING_REMOTE_DS: Error parsing position at index $i: $e');
            dev.log('🔴 STAKING_REMOTE_DS: Position data: ${dataList[i]}');
            // Continue parsing other positions
          }
        }
        dev.log(
            '👤 STAKING_REMOTE_DS: Successfully parsed ${positions.length} of ${dataList.length} positions');
        return positions;
      } else {
        throw ServerException(
            'Failed to fetch positions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log(
          '👤 STAKING_REMOTE_DS: getUserPositions() DioException: ${e.type}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const TimeoutException('Connection timeout');
      }
      throw NetworkException(e.message ?? 'Network error');
    } catch (e) {
      dev.log('👤 STAKING_REMOTE_DS: getUserPositions() Exception: $e');
      throw ServerException(e.toString());
    }
  }

  /// Stake into a pool
  Future<StakingPositionModel> stake({
    required String poolId,
    required double amount,
  }) async {
    try {
      final body = {'poolId': poolId, 'amount': amount};
      final response = await _client.post(
        ApiConstants.stakingPositions,
        data: body,
      );
      if (response.statusCode == 200) {
        final payload = _extractMapPayload(response.data);
        final positionJson = _extractNestedPosition(payload) ?? payload;
        return StakingPositionModel.fromJson(positionJson);
      }
      throw ServerException('Failed to stake: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const TimeoutException('Connection timeout');
      }
      throw NetworkException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Withdraw a staking position
  Future<StakingPositionModel> withdraw(String positionId) async {
    try {
      final url = '${ApiConstants.stakingWithdraw}/$positionId/withdraw';
      final response = await _client.post(url);
      if (response.statusCode == 200) {
        final payload = _extractMapPayload(response.data);
        final positionJson = _extractNestedPosition(payload) ?? payload;
        return StakingPositionModel.fromJson(positionJson);
      }
      throw ServerException('Failed to withdraw: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const TimeoutException('Connection timeout');
      }
      throw NetworkException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Claim rewards for a position
  Future<StakingPositionModel> claimRewards(String positionId) async {
    try {
      final url = '${ApiConstants.stakingClaim}/$positionId/claim';
      final response = await _client.post(url);
      if (response.statusCode == 200) {
        final payload = _extractMapPayload(response.data);
        final positionJson = _extractNestedPosition(payload);

        // Claim endpoint may not include a full position object.
        if (positionJson != null) {
          return StakingPositionModel.fromJson(positionJson);
        }

        final claimedAmount = (payload['claimedAmount'] as num?)?.toDouble() ??
            ((payload['data'] is Map<String, dynamic>)
                ? (((payload['data'] as Map<String, dynamic>)['claimedAmount']
                            as num?)
                        ?.toDouble() ??
                    0.0)
                : 0.0);

        return StakingPositionModel(
          id: positionId,
          poolId: '',
          status: 'ACTIVE',
          createdAt: DateTime.now(),
          endDate: null,
          amount: 0.0,
          earningsTotal: claimedAmount,
          earningsUnclaimed: 0.0,
          timeRemaining: null,
        );
      }
      throw ServerException('Failed to claim rewards: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const TimeoutException('Connection timeout');
      }
      throw NetworkException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Fetch overall staking statistics
  Future<StakingStatsModel> getStats() async {
    dev.log('📊 STAKING_REMOTE_DS: getStats() called');
    try {
      final response = await _client.get(ApiConstants.stakingStats);
      if (response.statusCode == 200) {
        dev.log('📊 STAKING_REMOTE_DS: getStats() success');
        final payload = _extractMapPayload(response.data);
        final data = (payload['data'] is Map<String, dynamic>)
            ? payload['data'] as Map<String, dynamic>
            : ((payload['stats'] is Map<String, dynamic>)
                ? payload['stats'] as Map<String, dynamic>
                : payload);
        return StakingStatsModel.fromJson(data);
      }
      throw ServerException(
          'Failed to fetch staking stats: ${response.statusCode}');
    } on DioException catch (e) {
      dev.log('📊 STAKING_REMOTE_DS: getStats() DioException: ${e.type}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const TimeoutException('Connection timeout');
      }
      throw NetworkException(e.message ?? 'Network error');
    } catch (e) {
      dev.log('📊 STAKING_REMOTE_DS: getStats() Exception: $e');
      throw ServerException(e.toString());
    }
  }

  /// Fetch pool analytics for a specific pool
  Future<PoolAnalyticsModel> getPoolAnalytics(
    String poolId, {
    String? timeframe,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (timeframe != null) params['timeframe'] = timeframe;
      final url = '${ApiConstants.stakingPoolAnalytics}/$poolId/analytics';
      final response = await _client.get(url, queryParameters: params);
      if (response.statusCode == 200) {
        final payload = _extractMapPayload(response.data);
        final data = (payload['analytics'] is Map<String, dynamic>)
            ? payload['analytics'] as Map<String, dynamic>
            : ((payload['data'] is Map<String, dynamic> &&
                    (payload['data'] as Map<String, dynamic>)['analytics']
                        is Map<String, dynamic>)
                ? (payload['data'] as Map<String, dynamic>)['analytics']
                    as Map<String, dynamic>
                : payload);
        return PoolAnalyticsModel.fromJson(data);
      }
      throw ServerException(
          'Failed to fetch pool analytics: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const TimeoutException('Connection timeout');
      }
      throw NetworkException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Map<String, dynamic> _extractMapPayload(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }
    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }
    throw const ServerException('Unexpected response format from server');
  }

  Map<String, dynamic>? _extractNestedPosition(Map<String, dynamic> payload) {
    if (payload['position'] is Map<String, dynamic>) {
      return payload['position'] as Map<String, dynamic>;
    }
    if (payload['data'] is Map<String, dynamic>) {
      final data = payload['data'] as Map<String, dynamic>;
      if (data['position'] is Map<String, dynamic>) {
        return data['position'] as Map<String, dynamic>;
      }
      if (data['id'] != null && data['poolId'] != null) {
        return data;
      }
    }
    if (payload['id'] != null && payload['poolId'] != null) {
      return payload;
    }
    return null;
  }
}
