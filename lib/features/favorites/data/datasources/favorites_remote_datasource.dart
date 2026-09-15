import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../models/service_model.dart';
import '../../../services/data/datasources/services_remote_datasource.dart';

abstract class FavoritesRemoteDataSource {
  Future<void> toggleFavorite(String serviceId);
  Future<bool> isFavorite(String serviceId);
  Future<List<String>> getFavoriteIds();
  Future<List<ServiceModel>> getFavoriteServices();
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  static final Set<String> _localFavoriteIds = {'srv_1', 'srv_2'};

  @override
  Future<void> toggleFavorite(String serviceId) async {
    try {
      await ApiClient.post(ApiEndpoints.toggleFavorite(serviceId), auth: true);
    } catch (_) {}

    if (_localFavoriteIds.contains(serviceId)) {
      _localFavoriteIds.remove(serviceId);
    } else {
      _localFavoriteIds.add(serviceId);
    }
  }

  @override
  Future<bool> isFavorite(String serviceId) async {
    try {
      final ids = await getFavoriteIds();
      return ids.contains(serviceId);
    } catch (_) {
      return _localFavoriteIds.contains(serviceId);
    }
  }

  @override
  Future<List<String>> getFavoriteIds() async {
    try {
      final data = await ApiClient.get(ApiEndpoints.favoriteIds, auth: true);
      final list = (data['ids'] as List<dynamic>? ?? []).cast<String>();
      if (list.isNotEmpty) return list;
    } catch (_) {}

    return _localFavoriteIds.toList();
  }

  @override
  Future<List<ServiceModel>> getFavoriteServices() async {
    try {
      final data = await ApiClient.get(ApiEndpoints.favorites, auth: true);
      final list = data['favorites'] as List<dynamic>? ?? [];
      final result = list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
      if (result.isNotEmpty) return result;
    } catch (_) {}

    final allServices = await ServicesRemoteDataSourceImpl().getServices();
    return allServices.where((s) => _localFavoriteIds.contains(s.id)).toList();
  }
}
