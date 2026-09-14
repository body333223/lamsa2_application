import '../../../models/service_model.dart';
import '../../services/domain/repositories/services_repository.dart';
import '../../services/data/repositories/services_repository_impl.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

/// Clean repository for Home feature utilizing ServicesRepository
class HomeRepository {
  final ServicesRepository _servicesRepository;

  HomeRepository({ServicesRepository? servicesRepository})
      : _servicesRepository = servicesRepository ?? ServicesRepositoryImpl();

  Future<List<ServiceModel>> getServices({String? category}) =>
      _servicesRepository.getServices(category: category);

  Future<List<ServiceModel>> getPopularServices() =>
      _servicesRepository.getPopularServices();

  Future<List<Map<String, dynamic>>> getSliders() =>
      _servicesRepository.getSliders();

  Future<List<String>> getCategories() =>
      _servicesRepository.getCategories();

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final data = await ApiClient.get(ApiEndpoints.me, auth: true);
      return data['user'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}
