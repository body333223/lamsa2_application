import '../../../../models/service_model.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl({FavoritesRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? FavoritesRemoteDataSourceImpl();

  @override
  Future<void> toggleFavorite(String serviceId) =>
      remoteDataSource.toggleFavorite(serviceId);

  @override
  Future<bool> isFavorite(String serviceId) =>
      remoteDataSource.isFavorite(serviceId);

  @override
  Future<List<String>> getFavoriteIds() =>
      remoteDataSource.getFavoriteIds();

  @override
  Future<List<ServiceModel>> getFavoriteServices() =>
      remoteDataSource.getFavoriteServices();
}
