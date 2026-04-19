import 'dart:async';
import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/get_cached_user_usecase.dart';
import '../models/eco_token_model.dart';
import '../models/eco_deposit_address_model.dart';
import '../models/eco_deposit_verification_model.dart';

abstract class EcoDepositRemoteDataSource {
  // Currency & Token Management
  Future<List<String>> fetchEcoCurrencies();
  Future<List<EcoTokenModel>> fetchEcoTokens(String currency);

  // Address Generation by Contract Type
  Future<EcoDepositAddressModel> generatePermitAddress(
      String currency, String chain);
  Future<EcoDepositAddressModel> generateNoPermitAddress(
      String currency, String chain);
  Future<EcoDepositAddressModel> generateNativeAddress(
      String currency, String chain);

  // Address Management
  Future<void> unlockAddress(String address);

  // WebSocket Monitoring
  Stream<EcoDepositVerificationModel> connectToEcoWebSocket();
  void startMonitoring({
    required String currency,
    required String chain,
    String? address,
  });
  void dispose();
}

@Injectable(as: EcoDepositRemoteDataSource)
class EcoDepositRemoteDataSourceImpl implements EcoDepositRemoteDataSource {
  final DioClient _dioClient;
  final GetCachedUserUseCase _getCachedUserUseCase;
  WebSocketChannel? _channel;
  StreamController<EcoDepositVerificationModel>? _controller;
  bool _isConnected = false;
  Completer<void>? _connectionCompleter;

  EcoDepositRemoteDataSourceImpl(this._dioClient, this._getCachedUserUseCase);

  @override
  Future<List<String>> fetchEcoCurrencies() async {
    dev.log('🔵 ECO_REMOTE_DS: Fetching ECO currencies');

    try {
      final response = await _dioClient.get(
        ApiConstants.ecoCurrencies,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as List<dynamic>;

        if (data.isEmpty) {
          throw Exception(
              'No ECO currencies are currently available for deposits');
        }

        final currencies = data
            .map((item) =>
                item['value'] as String? ?? item['currency'] as String? ?? '')
            .where((currency) => currency.isNotEmpty)
            .toList();

        if (currencies.isEmpty) {
          throw Exception(
              'No valid ECO currencies found. Please contact support.');
        }

        dev.log('✅ ECO_REMOTE_DS: Fetched ${currencies.length} currencies');
        return currencies;
      }

      throw Exception('Unable to load ECO currencies. Please try again later.');
    } on DioException catch (e) {
      dev.log('❌ ECO_REMOTE_DS: Network error: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('ECO deposits are not available at this time');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
            'Network connection failed. Please check your internet and try again.');
      }
    } catch (e) {
      dev.log('❌ ECO_REMOTE_DS: Failed to fetch currencies: $e');
      // Provide user-friendly error message
      if (e.toString().contains('No ECO currencies') ||
          e.toString().contains('not available') ||
          e.toString().contains('No valid ECO currencies')) {
        rethrow; // Keep the specific message
      }
      throw Exception('Failed to load ECO currencies. Please try again later.');
    }
  }

  @override
  Future<List<EcoTokenModel>> fetchEcoTokens(String currency) async {
    dev.log('🔵 ECO_REMOTE_DS: Fetching ECO tokens for currency: $currency');

    try {
      final response = await _dioClient.get(
        '${ApiConstants.ecoTokens}/$currency',
        queryParameters: {'action': 'deposit'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as List<dynamic>;

        if (data.isEmpty) {
          throw Exception('No tokens available for $currency currency');
        }

        final tokens = data
            .map((json) {
              try {
                // Parse limits and fee safely
                final tokenData = Map<String, dynamic>.from(json);

                // Handle limits field (can be null, string, or object)
                if (tokenData['limits'] == null) {
                  tokenData['limits'] = {
                    'deposit': {'min': 0.0, 'max': 1000000.0}
                  };
                } else if (tokenData['limits'] is String) {
                  try {
                    tokenData['limits'] = jsonDecode(tokenData['limits']);
                  } catch (e) {
                    dev.log(
                        '⚠️ ECO_REMOTE_DS: Invalid limits JSON for ${tokenData['name']}, using defaults');
                    tokenData['limits'] = {
                      'deposit': {'min': 0.0, 'max': 1000000.0}
                    };
                  }
                }

                // Handle fee field (can be null, string, or object)
                if (tokenData['fee'] == null) {
                  tokenData['fee'] = {'min': 0.0, 'percentage': 0.0};
                } else if (tokenData['fee'] is String) {
                  try {
                    tokenData['fee'] = jsonDecode(tokenData['fee']);
                  } catch (e) {
                    dev.log(
                        '⚠️ ECO_REMOTE_DS: Invalid fee JSON for ${tokenData['name']}, using defaults');
                    tokenData['fee'] = {'min': 0.0, 'percentage': 0.0};
                  }
                }

                // Ensure required fields exist
                tokenData['currency'] ??= currency;
                tokenData['status'] ??= true;

                return EcoTokenModel.fromJson(tokenData);
              } catch (e) {
                dev.log('⚠️ ECO_REMOTE_DS: Error parsing token data: $e');
                // Skip invalid tokens instead of failing the entire request
                return null;
              }
            })
            .where((token) => token != null)
            .cast<EcoTokenModel>()
            .toList();

        if (tokens.isEmpty) {
          throw Exception('No valid tokens found for $currency currency');
        }

        dev.log('✅ ECO_REMOTE_DS: Fetched ${tokens.length} tokens for $currency');
        return tokens;
      }

      throw Exception(
          'Unable to load $currency tokens. Please try again later.');
    } on DioException catch (e) {
      dev.log('❌ ECO_REMOTE_DS: Network error: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('$currency currency is not available for deposits');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
            'Network connection failed. Please check your internet and try again.');
      }
    } catch (e) {
      dev.log('❌ ECO_REMOTE_DS: Failed to fetch tokens: $e');
      // Provide user-friendly error message
      if (e.toString().contains('No tokens available') ||
          e.toString().contains('No valid tokens found') ||
          e.toString().contains('not available for deposits')) {
        rethrow; // Keep the specific message
      }
      throw Exception(
          'Failed to load $currency tokens. Please try again later.');
    }
  }

  @override
  Future<EcoDepositAddressModel> generatePermitAddress(
      String currency, String chain) async {
    return _generateAddress(currency, chain, 'PERMIT');
  }

  @override
  Future<EcoDepositAddressModel> generateNoPermitAddress(
      String currency, String chain) async {
    return _generateAddress(currency, chain, 'NO_PERMIT');
  }

  @override
  Future<EcoDepositAddressModel> generateNativeAddress(
      String currency, String chain) async {
    return _generateAddress(currency, chain, 'NATIVE');
  }

  Future<EcoDepositAddressModel> _generateAddress(
      String currency, String chain, String contractType) async {
    dev.log(
        '🔵 ECO_REMOTE_DS: Generating $contractType address for $currency on $chain');

    try {
      final response = await _dioClient.get(
        '${ApiConstants.ecoWallet}/$currency',
        queryParameters: {
          'contractType': contractType,
          'chain': chain,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Debug: Print the raw response data
        dev.log('🔍 ECO_REMOTE_DS: Raw response data: $data');
        dev.log('🔍 ECO_REMOTE_DS: Data type: ${data.runtimeType}');
        dev.log('🔍 ECO_REMOTE_DS: Data keys: ${data.keys.toList()}');
        dev.log('🔍 ECO_REMOTE_DS: Looking for chain: $chain');

        String? extractedAddress;
        String? extractedNetwork;
        String? walletId;
        String? walletStatus;

        // Debug: Check the type of the address field
        if (data.containsKey('address')) {
          dev.log('🔍 ECO_REMOTE_DS: Address field exists');
          dev.log(
              '🔍 ECO_REMOTE_DS: Address field type: ${data['address'].runtimeType}');
          dev.log('🔍 ECO_REMOTE_DS: Address field value: ${data['address']}');
          dev.log('🔍 ECO_REMOTE_DS: Is String? ${data['address'] is String}');
          dev.log(
              '🔍 ECO_REMOTE_DS: Is Map? ${data['address'] is Map<String, dynamic>}');
        }

        // Try to extract address from different response formats
        if (data.containsKey('address') && data['address'] is String) {
          final addressValue = data['address'] as String;

          // Check if it's a JSON string that needs to be parsed
          if (addressValue.startsWith('{') && addressValue.endsWith('}')) {
            // Format 1: JSON string that needs parsing {"BSC":{"address":"0x123",...}}
            dev.log('🔍 ECO_REMOTE_DS: Using Format 1 - JSON string parsing');
            try {
              final addressMap =
                  jsonDecode(addressValue) as Map<String, dynamic>;
              dev.log('🔍 ECO_REMOTE_DS: Parsed address map: $addressMap');

              if (addressMap.containsKey(chain) &&
                  addressMap[chain] is Map<String, dynamic>) {
                final chainData = addressMap[chain] as Map<String, dynamic>;
                dev.log('🔍 ECO_REMOTE_DS: Chain data for $chain: $chainData');
                extractedAddress = chainData['address'] as String?;
                extractedNetwork = chainData['network'] as String?;
                walletId = data['id']?.toString();
                walletStatus = data['status'] as String?;
              }
            } catch (e) {
              dev.log('❌ ECO_REMOTE_DS: Failed to parse address JSON: $e');
              // Fallback: treat as direct address string
              extractedAddress = addressValue;
            }
          } else {
            // Format 2: Direct address string "0x123..."
            dev.log('🔍 ECO_REMOTE_DS: Using Format 2 - Direct address string');
            extractedAddress = addressValue;
            extractedNetwork = data['network'] as String?;
            walletId = data['id']?.toString();
            walletStatus = data['status'] as String?;
          }
        } else if (data.containsKey('address') &&
            data['address'] is Map<String, dynamic>) {
          // Format 3: Nested address data {"address": {"BSC": {"address": "0x123", "network": "mainnet"}}}
          dev.log('🔍 ECO_REMOTE_DS: Using Format 3 - Nested address data');
          final addressData = data['address'] as Map<String, dynamic>;
          dev.log('🔍 ECO_REMOTE_DS: Address data: $addressData');

          if (addressData.containsKey(chain) &&
              addressData[chain] is Map<String, dynamic>) {
            final chainData = addressData[chain] as Map<String, dynamic>;
            dev.log('🔍 ECO_REMOTE_DS: Chain data for $chain: $chainData');
            extractedAddress = chainData['address'] as String?;
            extractedNetwork = chainData['network'] as String?;
            walletId = data['id']?.toString();
            walletStatus = data['status'] as String?;
          }
        } else if (data.containsKey(chain) &&
            data[chain] is Map<String, dynamic>) {
          // Format 4: Nested chain data {"BSC": {"address": "0x123", "network": "mainnet"}}
          dev.log(
              '🔍 ECO_REMOTE_DS: Using Format 4 - Nested chain data for $chain');
          final chainData = data[chain] as Map<String, dynamic>;
          dev.log('🔍 ECO_REMOTE_DS: Chain data: $chainData');
          extractedAddress = chainData['address'] as String?;
          extractedNetwork = chainData['network'] as String?;
          walletId = chainData['id']?.toString();
          walletStatus = chainData['status'] as String?;
        } else {
          // Format 5: Search through all keys for nested address data
          dev.log('🔍 ECO_REMOTE_DS: Using Format 5 - Searching all keys');
          for (final entry in data.entries) {
            if (entry.value is Map<String, dynamic>) {
              final nestedData = entry.value as Map<String, dynamic>;
              if (nestedData.containsKey('address')) {
                dev.log('🔍 ECO_REMOTE_DS: Found address in key: ${entry.key}');
                extractedAddress = nestedData['address'] as String?;
                extractedNetwork = nestedData['network'] as String?;
                walletId = nestedData['id']?.toString();
                walletStatus = nestedData['status'] as String?;
                break;
              }
            }
          }
        }

        dev.log('🔍 ECO_REMOTE_DS: Final extracted address: $extractedAddress');

        if (extractedAddress == null || extractedAddress.isEmpty) {
          throw Exception(
              'Unable to generate deposit address. Please try again later.');
        }

        final addressModel = EcoDepositAddressModel(
          address: extractedAddress,
          currency: currency,
          chain: chain,
          contractType: contractType,
          network: extractedNetwork,
          locked: contractType == 'NO_PERMIT',
          id: walletId,
          status: walletStatus,
        );

        dev.log(
            '✅ ECO_REMOTE_DS: Generated $contractType address: $extractedAddress');
        dev.log(
            '🔍 ECO_REMOTE_DS: Created model address field: ${addressModel.address}');
        dev.log(
            '🔍 ECO_REMOTE_DS: Created model currency: ${addressModel.currency}');
        dev.log('🔍 ECO_REMOTE_DS: Created model chain: ${addressModel.chain}');
        return addressModel;
      }

      throw Exception(
          'Unable to generate deposit address. Please try again later.');
    } on DioException catch (e) {
      dev.log('❌ ECO_REMOTE_DS: Network error: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception(
            '$currency on $chain network is not available for deposits');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid request. Please select a different token.');
      } else {
        throw Exception(
            'Network connection failed. Please check your internet and try again.');
      }
    } catch (e) {
      dev.log('❌ ECO_REMOTE_DS: Failed to generate address: $e');
      // Provide user-friendly error message
      if (e.toString().contains('Unable to generate') ||
          e.toString().contains('not available') ||
          e.toString().contains('Invalid request')) {
        rethrow; // Keep the specific message
      }
      throw Exception(
          'Failed to generate deposit address. Please try again later.');
    }
  }

  @override
  Future<void> unlockAddress(String address) async {
    dev.log('🔵 ECO_REMOTE_DS: Unlocking address: $address');

    try {
      final response = await _dioClient.get(
        ApiConstants.ecoDepositUnlock,
        queryParameters: {'address': address},
      );

      if (response.statusCode == 200) {
        dev.log('✅ ECO_REMOTE_DS: Address unlocked successfully');
      } else {
        throw Exception(
            'Failed to unlock address. Address may already be unlocked.');
      }
    } on DioException catch (e) {
      dev.log('❌ ECO_REMOTE_DS: Network error: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('Address not found or already unlocked');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid address format');
      } else {
        throw Exception(
            'Network connection failed. Please check your internet and try again.');
      }
    } catch (e) {
      dev.log('❌ ECO_REMOTE_DS: Failed to unlock address: $e');
      // Provide user-friendly error message
      if (e.toString().contains('not found') ||
          e.toString().contains('already unlocked') ||
          e.toString().contains('Invalid address')) {
        rethrow; // Keep the specific message
      }
      throw Exception('Failed to unlock address. Please try again later.');
    }
  }

  @override
  Stream<EcoDepositVerificationModel> connectToEcoWebSocket() {
    _controller = StreamController<EcoDepositVerificationModel>.broadcast();
    _connectionCompleter = Completer<void>();

    _connectEcoWebSocketAsync();

    return _controller!.stream;
  }

  Future<void> _connectEcoWebSocketAsync() async {
    try {
      // Get the current user to obtain userId for WebSocket auth
      final userResult = await _getCachedUserUseCase(NoParams());
      final userId = userResult.fold(
        (failure) => throw Exception('User not found: ${failure.message}'),
        (user) => user?.id ?? (throw Exception('User ID is null')),
      );

      final wsUrl =
          '${ApiConstants.wsBaseUrl}${ApiConstants.ecoDepositWs}?userId=$userId';

      dev.log('🔌 ECO_REMOTE_DS: Connecting to WebSocket: $wsUrl');

      if (Platform.isAndroid || Platform.isIOS) {
        _channel = IOWebSocketChannel.connect(
          Uri.parse(wsUrl),
          headers: {
            'User-Agent': '${AppConstants.appName} Mobile App',
          },
        );
      } else {
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      }

      _isConnected = true;
      _connectionCompleter?.complete();
      dev.log('🔌 ECO_REMOTE_DS: WebSocket connected');

      _channel!.stream.listen(
        (data) {
          try {
            final jsonData = jsonDecode(data) as Map<String, dynamic>;

            // Backend sends data in 'data' field within response
            if (jsonData.containsKey('data')) {
              final verificationData = jsonData['data'] as Map<String, dynamic>;
              final verification =
                  EcoDepositVerificationModel.fromJson(verificationData);
              _controller!.add(verification);
              dev.log(
                  '📨 ECO_REMOTE_DS: Received verification: ${verification.status}');
            }
          } catch (e) {
            dev.log('❌ ECO_REMOTE_DS: Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          dev.log('❌ ECO_REMOTE_DS: WebSocket error: $error');
          _isConnected = false;
          _controller!.addError(error);
        },
        onDone: () {
          dev.log('🔌 ECO_REMOTE_DS: WebSocket connection closed');
          _isConnected = false;
          _controller!.close();
        },
      );
    } catch (e) {
      dev.log('❌ ECO_REMOTE_DS: Failed to connect to WebSocket: $e');
      _connectionCompleter?.completeError(e);
      _controller!.addError(e);
    }
  }

  @override
  void startMonitoring({
    required String currency,
    required String chain,
    String? address,
  }) {
    _sendMonitoringMessage(
      currency: currency,
      chain: chain,
      address: address,
    );
  }

  Future<void> _sendMonitoringMessage({
    required String currency,
    required String chain,
    String? address,
  }) async {
    // Wait for the WebSocket connection to be established before sending
    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      dev.log('🔌 ECO_REMOTE_DS: Waiting for WebSocket connection...');
      await _connectionCompleter!.future;
    }

    if (!_isConnected || _channel == null) {
      dev.log('❌ ECO_REMOTE_DS: WebSocket not connected, cannot send monitoring request');
      return;
    }

    final message = {
      'payload': {
        'currency': currency,
        'chain': chain,
        if (address != null) 'address': address.toLowerCase(),
      },
    };

    dev.log('📤 ECO_REMOTE_DS: Sending monitoring request: $message');
    _channel!.sink.add(jsonEncode(message));
  }

  @override
  void dispose() {
    dev.log('🔌 ECO_REMOTE_DS: Disposing WebSocket connection');
    _isConnected = false;
    _channel?.sink.close();
    _controller?.close();
  }
}
