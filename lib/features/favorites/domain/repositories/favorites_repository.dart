import '../../../../models/service_model.dart';

abstract class FavoritesRepository {
  Future<void> toggleFavorite(String serviceId);
  Future<bool> isFavorite(String serviceId);
  Future<List<String>> getFavoriteIds();
  Future<List<ServiceModel>> getFavoriteServices();
}
