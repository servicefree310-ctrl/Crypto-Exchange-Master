import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/wallet_model.dart';

@injectable
class WalletRemoteDataSource {
  final DioClient _client;
  static const int _walletsPerPage = 100;
  static const int _maxWalletPages = 100;

  const WalletRemoteDataSource(this._client);

  /// Fetch all wallets grouped by type - matches v5 /api/finance/wallet
  Future<Map<String, List<WalletModel>>> getWallets() async {
    try {
      dev.log('🔵 WALLET_REMOTE_DS: Fetching all wallets from v5 API');

      final allItems = <dynamic>[];
      var page = 1;
      var totalPages = 1;

      while (page <= totalPages && page <= _maxWalletPages) {
        final response = await _client.get(
          ApiConstants.wallet,
          queryParameters: {
            'page': page,
            'perPage': _walletsPerPage,
            'sortOrder': 'asc',
          },
        );

        if (response.statusCode != 200) {
          dev.log(
              '🔴 WALLET_REMOTE_DS: API returned status code: ${response.statusCode}');
          throw ServerException(
              'Failed to fetch wallets: ${response.statusCode}');
        }

        final data = response.data;
        if (data is! Map<String, dynamic> || data['items'] is! List) {
          dev.log(
              '🔴 WALLET_REMOTE_DS: Invalid response format: missing items field');
          throw const ServerException('Invalid response format');
        }

        final items = data['items'] as List;
        allItems.addAll(items);

        final pagination = data['pagination'];
        if (pagination is Map<String, dynamic>) {
          totalPages = _toInt(pagination['totalPages']) ?? page;
        } else {
          totalPages = page;
        }

        dev.log(
            '🔵 WALLET_REMOTE_DS: Fetched page $page/$totalPages (${items.length} wallets)');

        // Safety guard if API returns empty pages unexpectedly.
        if (items.isEmpty) {
          break;
        }

        page++;
      }

      if (totalPages > _maxWalletPages) {
        dev.log(
            '🔴 WALLET_REMOTE_DS: Wallet pages exceeded safety limit ($_maxWalletPages)');
      }

      dev.log('🔵 WALLET_REMOTE_DS: Found ${allItems.length} wallets');

      if (allItems.isNotEmpty) {
        dev.log('🔵 WALLET_REMOTE_DS: Sample wallet structure:');
        dev.log('  ${allItems.first}');
      }

      // Group wallets by type
      final Map<String, List<WalletModel>> groupedWallets = {
        'FIAT': <WalletModel>[],
        'SPOT': <WalletModel>[],
        'ECO': <WalletModel>[],
        'FUTURES': <WalletModel>[],
      };

      for (final item in allItems) {
        try {
          final wallet = WalletModel.fromJson(item as Map<String, dynamic>);
          final type = wallet.type.name.toUpperCase();

          if (groupedWallets.containsKey(type)) {
            groupedWallets[type]!.add(wallet);
            dev.log(
                '🔵 WALLET_REMOTE_DS: Added $type wallet: ${wallet.currency} (balance: ${wallet.balance})');
          } else {
            dev.log(
                '🔴 WALLET_REMOTE_DS: Unknown wallet type: $type for ${wallet.currency}');
          }
        } catch (e) {
          dev.log('🔴 WALLET_REMOTE_DS: Failed to parse wallet item: $e');
          dev.log('  Item: $item');
        }
      }

      dev.log('🔵 WALLET_REMOTE_DS: Grouped wallets successfully');
      return groupedWallets;
    } on DioException catch (e) {
      dev.log(
          '🔴 WALLET_REMOTE_DS: Network error fetching wallets: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      } else if (e.response?.statusCode == 401) {
        throw const ServerException('Unauthorized');
      } else if (e.response?.statusCode == 404) {
        throw const ServerException('Wallets not found');
      } else {
        throw ServerException(e.message ?? 'Network error');
      }
    } catch (e) {
      dev.log('🔴 WALLET_REMOTE_DS: Unexpected error fetching wallets: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get wallets by type - compatible with repository interface
  Future<List<WalletModel>> getWalletsByType(String type) async {
    try {
      dev.log('🔵 WALLET_REMOTE_DS: Fetching $type wallets');

      final allWallets = await getWallets();
      return allWallets[type] ?? [];
    } catch (e) {
      dev.log('🔴 WALLET_REMOTE_DS: Error fetching $type wallets: $e');
      throw ServerException('Error fetching $type wallets: $e');
    }
  }

  /// Fetch PnL data for the last 28 days - matches v5 /api/finance/wallet?pnl=true
  Future<Map<String, dynamic>> getPnlData() async {
    try {
      dev.log('🔵 WALLET_REMOTE_DS: Fetching PnL data from API');

      final response = await _client.get(ApiConstants.wallet, queryParameters: {
        'pnl': 'true',
      });

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          dev.log('🔵 WALLET_REMOTE_DS: Successfully fetched PnL data:');
          dev.log('  - Today: ${data['today']}');
          dev.log('  - Yesterday: ${data['yesterday']}');
          dev.log('  - PnL: ${data['pnl']}');
          dev.log('  - Chart points: ${(data['chart'] as List?)?.length ?? 0}');
          return data;
        } else {
          dev.log('🔴 WALLET_REMOTE_DS: Invalid PnL response format');
          throw const ServerException('Invalid PnL response format');
        }
      } else {
        dev.log(
            '🔴 WALLET_REMOTE_DS: PnL API returned status code: ${response.statusCode}');
        throw ServerException(
            'Failed to fetch PnL data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log(
          '🔴 WALLET_REMOTE_DS: Network error fetching PnL data: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      } else if (e.response?.statusCode == 401) {
        throw const ServerException('Unauthorized');
      } else if (e.response?.statusCode == 404) {
        throw const ServerException('PnL data not found');
      } else {
        throw ServerException(e.message ?? 'Network error');
      }
    } catch (e) {
      dev.log('🔴 WALLET_REMOTE_DS: Unexpected error fetching PnL data: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Fetch specific wallet details - matches v5 /api/finance/wallet/{type}/{currency}
  Future<WalletModel> getWallet(String type, String currency) async {
    try {
      dev.log(
          '🔵 WALLET_REMOTE_DS: Fetching wallet details for $type/$currency');

      final response =
          await _client.get('${ApiConstants.wallet}/$type/$currency');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final wallet = WalletModel.fromJson(data);
          dev.log('🔵 WALLET_REMOTE_DS: Successfully fetched wallet details');
          return wallet;
        } else {
          dev.log('🔴 WALLET_REMOTE_DS: Invalid wallet response format');
          throw const ServerException('Invalid wallet response format');
        }
      } else {
        dev.log(
            '🔴 WALLET_REMOTE_DS: Wallet API returned status code: ${response.statusCode}');
        throw ServerException('Failed to fetch wallet: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dev.log(
          '🔴 WALLET_REMOTE_DS: Network error fetching wallet: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      } else if (e.response?.statusCode == 401) {
        throw const ServerException('Unauthorized');
      } else if (e.response?.statusCode == 404) {
        throw const ServerException('Wallet not found');
      } else {
        throw ServerException(e.message ?? 'Network error');
      }
    } catch (e) {
      dev.log('🔴 WALLET_REMOTE_DS: Unexpected error fetching wallet: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Get wallet by ID - compatibility method
  Future<WalletModel> getWalletById(String walletId) async {
    try {
      dev.log('🔵 WALLET_REMOTE_DS: Fetching wallet by ID: $walletId');

      final allWallets = await getWallets();
      for (final walletList in allWallets.values) {
        for (final wallet in walletList) {
          if (wallet.id == walletId) {
            return wallet;
          }
        }
      }

      throw const ServerException('Wallet not found');
    } catch (e) {
      dev.log('🔴 WALLET_REMOTE_DS: Error fetching wallet by ID: $e');
      throw ServerException('Error fetching wallet by ID: $e');
    }
  }

  /// Update wallet balance - placeholder implementation
  Future<WalletModel> updateWalletBalance(
      String walletId, double newBalance) async {
    try {
      dev.log(
          '🔵 WALLET_REMOTE_DS: Update wallet balance placeholder - fetching updated wallet');

      // For now, just return the current wallet since v5 doesn't have direct balance update
      return await getWalletById(walletId);
    } catch (e) {
      dev.log('🔴 WALLET_REMOTE_DS: Error updating wallet balance: $e');
      throw ServerException('Error updating wallet balance: $e');
    }
  }

  /// Create wallet - placeholder implementation
  Future<WalletModel> createWallet(String type, String currency) async {
    try {
      dev.log(
          '🔵 WALLET_REMOTE_DS: Create wallet placeholder for $type/$currency');

      // For now, just fetch existing wallet since v5 auto-creates wallets
      return await getWallet(type, currency);
    } catch (e) {
      dev.log('🔴 WALLET_REMOTE_DS: Error creating wallet: $e');
      throw ServerException('Error creating wallet: $e');
    }
  }

  /// Transfer funds - placeholder implementation
  Future<Map<String, dynamic>> transferFunds({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? description,
  }) async {
    try {
      dev.log('🔵 WALLET_REMOTE_DS: Transfer funds placeholder');

      // Return placeholder response
      return {
        'success': false,
        'message': 'Transfer not implemented in basic version'
      };
    } catch (e) {
      dev.log('🔴 WALLET_REMOTE_DS: Error transferring funds: $e');
      throw ServerException('Error transferring funds: $e');
    }
  }

  /// Transfer to user - placeholder implementation
  Future<Map<String, dynamic>> transferToUser({
    required String fromWalletId,
    required String recipientUserId,
    required double amount,
    String? description,
  }) async {
    try {
      dev.log('🔵 WALLET_REMOTE_DS: Transfer to user placeholder');

      // Return placeholder response
      return {
        'success': false,
        'message': 'Transfer not implemented in basic version'
      };
    } catch (e) {
      dev.log('🔴 WALLET_REMOTE_DS: Error transferring to user: $e');
      throw ServerException('Error transferring to user: $e');
    }
  }

  /// Get wallet performance - maps to PnL data
  Future<Map<String, dynamic>> getWalletPerformance() async {
    return await getPnlData();
  }

  /// Get total balance in USD - placeholder calculation
  Future<double> getTotalBalanceUSD() async {
    try {
      dev.log('🔵 WALLET_REMOTE_DS: Calculating total balance');

      final allWallets = await getWallets();
      double totalBalance = 0.0;

      for (final walletList in allWallets.values) {
        for (final wallet in walletList) {
          totalBalance += wallet.balance;
        }
      }

      return totalBalance;
    } catch (e) {
      dev.log('🔴 WALLET_REMOTE_DS: Error calculating total balance: $e');
      throw ServerException('Error calculating total balance: $e');
    }
  }

  /// Get wallet stats including total balance and 24h change
  Future<Map<String, dynamic>> getWalletStats() async {
    try {
      dev.log('🔵 WALLET_REMOTE_DS: Calculating wallet stats');

      // Fetch both wallet data and PnL data in parallel
      final results = await Future.wait([
        getWallets(),
        getPnlData(),
      ]);

      final walletsResponse = results[0] as Map<String, List<WalletModel>>;
      final pnlData = results[1];

      // Calculate total balance across all wallet types
      double totalBalance = 0.0;
      int totalWallets = 0;

      for (final walletList in walletsResponse.values) {
        for (final wallet in walletList) {
          totalBalance += wallet.balance;
          totalWallets++;
        }
      }

      // Extract 24h change from PnL data
      double totalChange = 0.0;
      double totalChangePercent = 0.0;

      if (pnlData.containsKey('pnl')) {
        totalChange = (pnlData['pnl'] as num?)?.toDouble() ?? 0.0;
      }

      if (pnlData.containsKey('today') && pnlData.containsKey('yesterday')) {
        final today = (pnlData['today'] as num?)?.toDouble() ?? 0.0;
        final yesterday = (pnlData['yesterday'] as num?)?.toDouble() ?? 1.0;
        if (yesterday > 0) {
          totalChangePercent = ((today - yesterday) / yesterday) * 100;
        }
      }

      final stats = {
        'totalBalance': totalBalance,
        'totalChange': totalChange,
        'totalChangePercent': totalChangePercent,
        'totalWallets': totalWallets,
      };

      dev.log(
          '🔵 WALLET_REMOTE_DS: Successfully calculated wallet stats: $stats');
      return stats;
    } catch (e) {
      dev.log('🔴 WALLET_REMOTE_DS: Error calculating wallet stats: $e');
      // Return default stats if calculation fails
      return {
        'totalBalance': 0.0,
        'totalChange': 0.0,
        'totalChangePercent': 0.0,
        'totalWallets': 0,
      };
    }
  }

  /// Fetch wallet balances for both currency and pair using symbol endpoint
  Future<Map<String, double>> getSymbolBalances({
    required String type, // SPOT
    required String currency,
    required String pair,
  }) async {
    try {
      final query = {
        'type': type,
        'currency': currency,
        'pair': pair,
      };
      dev.log('🔵 WALLET_REMOTE_DS: Fetching symbol balances $currency/$pair');
      final response = await _client.get(ApiConstants.walletSymbolBalance,
          queryParameters: query);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return {
          'CURRENCY': (data['CURRENCY'] ?? 0).toDouble(),
          'PAIR': (data['PAIR'] ?? 0).toDouble(),
        };
      }

      throw const ServerException('Failed to fetch symbol balances');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
