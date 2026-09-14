import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../models/service_model.dart';

abstract class ServicesRemoteDataSource {
  Future<List<ServiceModel>> getServices({String? category});
  Future<List<ServiceModel>> getPopularServices();
  Future<List<ServiceModel>> searchServices(String query, String category);
  Future<ServiceModel?> getServiceById(String id);
  Future<List<String>> getCategories();
  Future<List<Map<String, dynamic>>> getSliders();
}

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  @override
  Future<List<ServiceModel>> getServices({String? category}) async {
    final query = <String, String>{};
    if (category != null && category.isNotEmpty && category != 'الكل' && category != 'all') {
      query['category'] = category;
    }
    final data = await ApiClient.get(ApiEndpoints.services, query: query);
    final list = data['services'] as List<dynamic>? ?? [];
    return list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ServiceModel>> getPopularServices() async {
    final data = await ApiClient.get(ApiEndpoints.popularServices);
    final list = data['services'] as List<dynamic>? ?? [];
    return list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ServiceModel>> searchServices(String query, String category) async {
    final data = await ApiClient.get(ApiEndpoints.searchServices, query: {
      'q': query,
      'category': category,
    });
    final list = data['services'] as List<dynamic>? ?? [];
    return list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ServiceModel?> getServiceById(String id) async {
    try {
      final data = await ApiClient.get(ApiEndpoints.serviceById(id));
      return ServiceModel.fromJson(data['service'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    final data = await ApiClient.get(ApiEndpoints.categories);
    return (data['categories'] as List<dynamic>? ?? []).cast<String>();
  }

  @override
  Future<List<Map<String, dynamic>>> getSliders() async {
    final data = await ApiClient.get(ApiEndpoints.sliders);
    return (data['sliders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }
}
