import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../models/service_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<void> toggleFavorite(String serviceId);
  Future<bool> isFavorite(String serviceId);
  Future<List<String>> getFavoriteIds();
  Future<List<ServiceModel>> getFavoriteServices();
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  @override
  Future<void> toggleFavorite(String serviceId) async {
    await ApiClient.post(ApiEndpoints.toggleFavorite(serviceId), auth: true);
  }

  @override
  Future<bool> isFavorite(String serviceId) async {
    try {
      final ids = await getFavoriteIds();
      return ids.contains(serviceId);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<String>> getFavoriteIds() async {
    try {
      final data = await ApiClient.get(ApiEndpoints.favoriteIds, auth: true);
      return (data['ids'] as List<dynamic>? ?? []).cast<String>();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<ServiceModel>> getFavoriteServices() async {
    final data = await ApiClient.get(ApiEndpoints.favorites, auth: true);
    final list = data['favorites'] as List<dynamic>? ?? [];
    return list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
