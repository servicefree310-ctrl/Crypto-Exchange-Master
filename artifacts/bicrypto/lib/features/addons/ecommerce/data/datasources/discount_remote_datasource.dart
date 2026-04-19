import 'package:injectable/injectable.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/api_constants.dart';
import '../models/discount_model.dart';

/// Remote data source for discount/coupon operations
abstract class DiscountRemoteDataSource {
  /// Validates a discount code
  Future<DiscountModel> validateDiscount(String code);
}

@Injectable(as: DiscountRemoteDataSource)
class DiscountRemoteDataSourceImpl implements DiscountRemoteDataSource {
  const DiscountRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DiscountModel> validateDiscount(String code) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.ecommerceDiscountValidate,
        data: {
          'code': code.trim().toUpperCase(),
        },
      );

      // Success response
      if (response.statusCode == 200) {
        return DiscountModelFactory.fromValidationResponse(response.data);
      }

      // Error response (400 - invalid/expired discount)
      if (response.statusCode == 400) {
        return DiscountModelFactory.fromErrorResponse(response.data, code);
      }

      // Other error status codes
      throw Exception('Failed to validate discount: ${response.statusMessage}');
    } catch (e) {
      // Network or parsing error
      return DiscountModelFactory.fromErrorResponse(
        {'error': 'Failed to validate discount code'},
        code,
      );
    }
  }
}
