import '../../../../models/service_model.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_datasource.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource remoteDataSource;

  ServicesRepositoryImpl({ServicesRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? ServicesRemoteDataSourceImpl();

  @override
  Future<List<ServiceModel>> getServices({String? category}) =>
      remoteDataSource.getServices(category: category);

  @override
  Future<List<ServiceModel>> getPopularServices() =>
      remoteDataSource.getPopularServices();

  @override
  Future<List<ServiceModel>> searchServices(String query, String category) =>
      remoteDataSource.searchServices(query, category);

  @override
  Future<ServiceModel?> getServiceById(String id) =>
      remoteDataSource.getServiceById(id);

  @override
  Future<List<String>> getCategories() =>
      remoteDataSource.getCategories();

  @override
  Future<List<Map<String, dynamic>>> getSliders() =>
      remoteDataSource.getSliders();
}
