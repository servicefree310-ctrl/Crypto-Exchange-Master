import 'dart:convert';
import 'dart:developer' as dev;
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/wallet_entity.dart';
import '../models/wallet_model.dart';

@injectable
class WalletCacheDataSource {
  final FlutterSecureStorage _secureStorage;
  static const String _walletsKey = 'cached_wallets';
  static const String _cacheTimestampKey = 'wallets_cache_timestamp';
  static const String _individualWalletPrefix = 'wallet_';
  static const Duration _cacheValidDuration =
      Duration(minutes: 5); // 5-minute cache

  const WalletCacheDataSource(this._secureStorage);

  /// Get cached wallets grouped by type
  Future<Map<String, List<WalletModel>>?> getCachedWallets() async {
    try {
      dev.log('🔵 WALLET_CACHE: Checking cached wallets');

      // Check if cache is still valid
      final timestampStr = await _secureStorage.read(key: _cacheTimestampKey);
      if (timestampStr == null) {
        dev.log('🔵 WALLET_CACHE: No cache timestamp found');
        return null;
      }

      final cacheTimestamp =
          DateTime.fromMillisecondsSinceEpoch(int.parse(timestampStr));
      final now = DateTime.now();

      if (now.difference(cacheTimestamp) > _cacheValidDuration) {
        dev.log('🔵 WALLET_CACHE: Cache expired, clearing');
        await clearWalletCache();
        return null;
      }

      // Read cached wallets
      final walletsJson = await _secureStorage.read(key: _walletsKey);
      if (walletsJson == null) {
        dev.log('🔵 WALLET_CACHE: No cached wallets found');
        return null;
      }

      final walletsData = jsonDecode(walletsJson) as Map<String, dynamic>;
      final Map<String, List<WalletModel>> cachedWallets = {};

      for (final entry in walletsData.entries) {
        final walletsList = entry.value as List<dynamic>;
        final wallets = walletsList
            .map((json) => WalletModel.fromJson(json as Map<String, dynamic>))
            .toList();

        cachedWallets[entry.key] = wallets;
      }

      dev.log(
          '🔵 WALLET_CACHE: Found cached wallets with ${cachedWallets.length} types');
      return cachedWallets;
    } catch (e) {
      dev.log('🔴 WALLET_CACHE: Error reading cached wallets: $e');
      await clearWalletCache(); // Clear corrupted cache
      return null;
    }
  }

  /// Get a specific cached wallet by ID
  Future<WalletEntity?> getCachedWallet(String walletId) async {
    try {
      dev.log('🔵 WALLET_CACHE: Checking cached wallet: $walletId');

      final walletJson =
          await _secureStorage.read(key: '$_individualWalletPrefix$walletId');
      if (walletJson == null) {
        dev.log('🔵 WALLET_CACHE: No cached wallet found for ID: $walletId');
        return null;
      }

      final walletData = jsonDecode(walletJson) as Map<String, dynamic>;
      final wallet = WalletModel.fromJson(walletData);

      dev.log('🔵 WALLET_CACHE: Found cached wallet: $walletId');
      return wallet.toEntity();
    } catch (e) {
      dev.log('🔴 WALLET_CACHE: Error reading cached wallet: $e');
      // Remove corrupted individual wallet cache
      await _secureStorage.delete(key: '$_individualWalletPrefix$walletId');
      return null;
    }
  }

  /// Cache wallets grouped by type
  Future<void> cacheWallets(Map<String, List<WalletModel>> wallets) async {
    try {
      dev.log('🔵 WALLET_CACHE: Caching ${wallets.length} wallet types');

      final walletsData = <String, dynamic>{};

      for (final entry in wallets.entries) {
        walletsData[entry.key] =
            entry.value.map((wallet) => wallet.toJson()).toList();
      }

      final walletsJson = jsonEncode(walletsData);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      await Future.wait([
        _secureStorage.write(key: _walletsKey, value: walletsJson),
        _secureStorage.write(key: _cacheTimestampKey, value: timestamp),
      ]);

      // Also cache individual wallets for quick access
      for (final walletList in wallets.values) {
        for (final wallet in walletList) {
          await cacheWallet(wallet);
        }
      }

      dev.log('🔵 WALLET_CACHE: Wallets cached successfully');
    } catch (e) {
      dev.log('🔴 WALLET_CACHE: Error caching wallets: $e');
    }
  }

  /// Cache a single wallet
  Future<void> cacheWallet(WalletModel wallet) async {
    try {
      dev.log('🔵 WALLET_CACHE: Caching individual wallet: ${wallet.id}');

      final walletJson = jsonEncode(wallet.toJson());
      await _secureStorage.write(
        key: '$_individualWalletPrefix${wallet.id}',
        value: walletJson,
      );

      dev.log('🔵 WALLET_CACHE: Individual wallet cached: ${wallet.id}');
    } catch (e) {
      dev.log('🔴 WALLET_CACHE: Error caching individual wallet: $e');
    }
  }

  /// Update cached wallet balance
  Future<void> updateCachedWalletBalance(
      String walletId, double newBalance) async {
    try {
      dev.log(
          '🔵 WALLET_CACHE: Updating cached wallet balance: $walletId -> $newBalance');

      // Get the current cached wallet
      final cachedWalletEntity = await getCachedWallet(walletId);
      if (cachedWalletEntity == null) {
        dev.log('🔵 WALLET_CACHE: No cached wallet found to update balance');
        return;
      }

      // Create updated wallet model
      final updatedWallet = WalletModel.fromEntity(cachedWalletEntity).copyWith(
        balance: newBalance,
        updatedAt: DateTime.now(),
      );

      await cacheWallet(updatedWallet);

      // Also update in the main wallets cache if it exists
      final cachedWallets = await getCachedWallets();
      if (cachedWallets != null) {
        final walletType = updatedWallet.type.name;
        final typeWallets = cachedWallets[walletType] ?? [];

        final walletIndex = typeWallets.indexWhere((w) => w.id == walletId);
        if (walletIndex >= 0) {
          typeWallets[walletIndex] = updatedWallet;
          cachedWallets[walletType] = typeWallets;
          await cacheWallets(cachedWallets);
        }
      }

      dev.log('🔵 WALLET_CACHE: Wallet balance updated in cache');
    } catch (e) {
      dev.log('🔴 WALLET_CACHE: Error updating cached wallet balance: $e');
    }
  }

  /// Clear all wallet cache
  Future<void> clearWalletCache() async {
    try {
      dev.log('🔵 WALLET_CACHE: Clearing all wallet cache');

      // Get all keys to find individual wallet cache entries
      final allKeys = await _secureStorage.readAll();
      final walletKeys = allKeys.keys
          .where((key) => key.startsWith(_individualWalletPrefix))
          .toList();

      // Delete main cache
      await Future.wait([
        _secureStorage.delete(key: _walletsKey),
        _secureStorage.delete(key: _cacheTimestampKey),
        // Delete all individual wallet caches
        ...walletKeys.map((key) => _secureStorage.delete(key: key)),
      ]);

      dev.log('🔵 WALLET_CACHE: All wallet cache cleared');
    } catch (e) {
      dev.log('🔴 WALLET_CACHE: Error clearing wallet cache: $e');
    }
  }
}
