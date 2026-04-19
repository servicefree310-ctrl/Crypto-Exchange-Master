import 'package:injectable/injectable.dart';
import '../../../../../core/network/api_client.dart';
import '../models/creator_investor_model.dart';

@injectable
class CreatorInvestorRemoteDataSource {
  const CreatorInvestorRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CreatorInvestorModel>> getInvestors({
    int page = 1,
    int limit = 10,
    String? sortField,
    String? sortDirection,
    String? search,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (sortField != null) 'sortField': sortField,
      if (sortDirection != null) 'sortDirection': sortDirection,
      if (search != null) 'search': search,
    };

    final response = await _apiClient.get(
      '/api/ext/ico/creator/investor',
      queryParameters: queryParams,
    );

    final items = response.data['items'] as List;
    return items.map((item) => CreatorInvestorModel.fromJson(item)).toList();
  }
}
