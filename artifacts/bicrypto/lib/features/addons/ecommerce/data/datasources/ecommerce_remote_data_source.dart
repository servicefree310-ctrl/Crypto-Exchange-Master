import 'package:injectable/injectable.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class EcommerceRemoteDataSource {
  Future<List<ProductModel>> getProducts();

  Future<ProductModel> getProductBySlug(String slug);

  Future<List<CategoryModel>> getCategories();

  Future<CategoryModel> getCategoryBySlug(String slug);

  Future<List<ProductModel>> getProductsByCategory(String categorySlug);
}

@Injectable(as: EcommerceRemoteDataSource)
class EcommerceRemoteDataSourceImpl implements EcommerceRemoteDataSource {
  const EcommerceRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await _apiClient.get(ApiConstants.ecommerceProducts);

    return (response.data as List)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async {
    final response = await _apiClient.get(
      '${ApiConstants.ecommerceProduct}/$slug',
    );

    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get(ApiConstants.ecommerceCategories);

    return (response.data as List)
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CategoryModel> getCategoryBySlug(String slug) async {
    final response = await _apiClient.get(
      '${ApiConstants.ecommerceCategory}/$slug',
    );

    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categorySlug) async {
    final response = await _apiClient.get(
      '${ApiConstants.ecommerceCategory}/$categorySlug/product',
    );

    return (response.data as List)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
