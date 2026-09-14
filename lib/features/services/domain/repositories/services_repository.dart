import '../../../../models/service_model.dart';

abstract class ServicesRepository {
  Future<List<ServiceModel>> getServices({String? category});
  Future<List<ServiceModel>> getPopularServices();
  Future<List<ServiceModel>> searchServices(String query, String category);
  Future<ServiceModel?> getServiceById(String id);
  Future<List<String>> getCategories();
  Future<List<Map<String, dynamic>>> getSliders();
}
