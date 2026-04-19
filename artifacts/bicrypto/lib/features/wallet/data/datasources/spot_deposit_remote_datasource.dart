import 'dart:async';
import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:developer' as dev;
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/domain/usecases/get_cached_user_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../models/spot_currency_model.dart';
import '../models/spot_network_model.dart';
import '../models/spot_deposit_address_model.dart';
import '../models/spot_deposit_transaction_model.dart';

abstract class SpotDepositRemoteDataSource {
  Future<List<SpotCurrencyModel>> fetchSpotCurrencies();

  Future<List<SpotNetworkModel>> fetchSpotNetworks(String currency);

  Future<SpotDepositAddressModel> generateSpotDepositAddress({
    required String currency,
    required String network,
  });

  Future<SpotDepositTransactionModel> createSpotDeposit({
    required String currency,
    required String chain,
    required String transactionHash,
  });

  Stream<Map<String, dynamic>> connectToVerificationStream(
      String transactionId);

  void startVerification(String transactionId);

  void stopVerification();
}

@Injectable(as: SpotDepositRemoteDataSource)
class SpotDepositRemoteDataSourceImpl implements SpotDepositRemoteDataSource {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;
  final GetCachedUserUseCase _getCachedUserUseCase;
  WebSocketChannel? _webSocketChannel;
  StreamController<Map<String, dynamic>>? _streamController;

  SpotDepositRemoteDataSourceImpl(
    this._dioClient,
    this._secureStorage,
    this._getCachedUserUseCase,
  );

  @override
  Future<List<SpotCurrencyModel>> fetchSpotCurrencies() async {
    final response = await _dioClient.get(ApiConstants.spotCurrencies);

    final List<dynamic> data = response.data;
    return data.map((json) => SpotCurrencyModel.fromJson(json)).toList();
  }

  @override
  Future<List<SpotNetworkModel>> fetchSpotNetworks(String currency) async {
    final response = await _dioClient.get(
      '${ApiConstants.spotNetworks}/$currency',
      queryParameters: {'action': 'deposit'},
    );

    final List<dynamic> data = response.data;
    return data.map((json) => SpotNetworkModel.fromJson(json)).toList();
  }

  @override
  Future<SpotDepositAddressModel> generateSpotDepositAddress({
    required String currency,
    required String network,
  }) async {
    final response = await _dioClient.get(
      '${ApiConstants.spotDepositAddress}/$currency/$network',
    );

    return SpotDepositAddressModel.fromJson(response.data);
  }

  @override
  Future<SpotDepositTransactionModel> createSpotDeposit({
    required String currency,
    required String chain,
    required String transactionHash,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.spotDeposit,
      data: {
        'currency': currency,
        'chain': chain,
        'trx': transactionHash,
      },
    );

    return SpotDepositTransactionModel.fromJson(response.data);
  }

  @override
  Stream<Map<String, dynamic>> connectToVerificationStream(
      String transactionId) async* {
    try {
      // Get the current user to obtain userId
      final userResult = await _getCachedUserUseCase(NoParams());
      final userId = userResult.fold(
        (failure) => throw Exception('User not found: ${failure.message}'),
        (user) => user?.id ?? (throw Exception('User ID is null')),
      );

      // Construct WebSocket URL with userId like v5 frontend does
      final wsUrl =
          '${ApiConstants.wsBaseUrl}${ApiConstants.spotDepositWs}?userId=$userId';

      dev.log('=== SPOT DEPOSIT WEBSOCKET ===');
      dev.log('🔗 Connecting to SPOT WebSocket: $wsUrl');
      dev.log('📊 Transaction ID: $transactionId');
      dev.log('👤 User ID: $userId');

      // Create WebSocket connection with proper error handling
      late WebSocketChannel channel;

      try {
        if (Platform.isAndroid || Platform.isIOS) {
          // Use IOWebSocketChannel for mobile platforms
          channel = IOWebSocketChannel.connect(
            Uri.parse(wsUrl),
            headers: {
              'User-Agent': '${AppConstants.appName} Mobile App',
            },
          );
        } else {
          // Fallback for other platforms
          channel = WebSocketChannel.connect(Uri.parse(wsUrl));
        }

        dev.log('🟢 WebSocket connected successfully');

        // Send subscription message as soon as connected
        // Backend expects { payload: { trx } } where trx is the blockchain transaction hash (referenceId)
        final subscriptionMessage = {
          'payload': {
            'trx': transactionId,
          },
        };

        dev.log('📤 Sending subscription message: $subscriptionMessage');
        dev.log('🔵 WebSocket: Subscribing to transaction verification...');
        channel.sink.add(jsonEncode(subscriptionMessage));

        // Listen to the stream
        await for (final message in channel.stream) {
          try {
            dev.log('=== WEBSOCKET MESSAGE RECEIVED ===');
            dev.log('📥 Raw message: $message');
            final data = jsonDecode(message) as Map<String, dynamic>;
            dev.log('🔍 Parsed data: $data');
            dev.log('📊 Message type: ${data['type'] ?? 'unknown'}');
            dev.log('📊 Stream: ${data['stream'] ?? 'unknown'}');

            // Filter out announcement messages - only process verification messages
            if (data['type'] == 'announcements') {
              dev.log('📢 Ignoring announcement message');
              continue;
            }

            // Only process verification stream messages
            if (data['stream'] != 'verification') {
              dev.log('🔄 Ignoring non-verification message');
              continue;
            }

            // Extract the actual verification data
            final verificationData = data['data'] as Map<String, dynamic>?;
            if (verificationData == null) {
              dev.log('⚠️ No verification data in message');
              continue;
            }

            dev.log('📊 Status: ${verificationData['status']}');
            dev.log('📝 Message: ${verificationData['message'] ?? 'No message'}');
            dev.log('========================');

            // Yield the verification data (not the wrapper)
            yield verificationData;

            // If we receive a successful verification, close the connection
            if (verificationData['status'] == 200 ||
                verificationData['status'] == 201) {
              dev.log('✅ DEPOSIT VERIFIED SUCCESSFULLY!');
              dev.log('🎉 Transaction confirmed, closing WebSocket');
              break;
            } else if (verificationData['status'] == 404) {
              dev.log('❓ Transaction not found yet, continuing to listen...');
            } else {
              dev.log(
                  '📍 Status ${verificationData['status']}: ${verificationData['message'] ?? 'No message'}');
            }
          } catch (e) {
            dev.log('❌ Error parsing WebSocket message: $e');
            dev.log('🔍 Raw message was: $message');
            // Don't throw exception for parsing errors, just continue listening
            continue;
          }
        }
      } finally {
        // Ensure the channel is properly closed
        try {
          channel.sink.close();
          dev.log('🔴 WebSocket connection closed');
        } catch (e) {
          dev.log('⚠️ Error closing WebSocket: $e');
        }
      }
    } catch (e) {
      dev.log('❌ WebSocket connection error: $e');
      throw Exception('Failed to connect to verification service: $e');
    }
  }

  @override
  void startVerification(String transactionId) {
    if (_webSocketChannel != null) {
      final message = jsonEncode({
        'action': 'SUBSCRIBE',
        'payload': {'trx': transactionId}
      });
      dev.log('🔵 SPOT_DEPOSIT_WS: Sending verification message: $message');
      _webSocketChannel!.sink.add(message);
    } else {
      dev.log('🔴 SPOT_DEPOSIT_WS: WebSocket not connected');
    }
  }

  @override
  void stopVerification() {
    dev.log('🔵 SPOT_DEPOSIT_WS: Stopping verification');
    _webSocketChannel?.sink.close();
    _streamController?.close();
    _webSocketChannel = null;
    _streamController = null;
  }
}
