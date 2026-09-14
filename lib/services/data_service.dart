import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../features/services/domain/repositories/services_repository.dart';
import '../features/services/data/repositories/services_repository_impl.dart';
import '../features/bookings/domain/repositories/bookings_repository.dart';
import '../features/bookings/data/repositories/bookings_repository_impl.dart';
import '../features/favorites/domain/repositories/favorites_repository.dart';
import '../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../features/notifications/domain/repositories/notifications_repository.dart';
import '../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../features/support/domain/repositories/chat_repository.dart';
import '../features/support/data/repositories/chat_repository_impl.dart';

/// Clean Architecture unified DataService facade.
/// Delegates all operations to domain-specific repositories.
class DataService {
  final ServicesRepository servicesRepository;
  final BookingsRepository bookingsRepository;
  final FavoritesRepository favoritesRepository;
  final NotificationsRepository notificationsRepository;
  final ChatRepository chatRepository;

  DataService({
    ServicesRepository? servicesRepository,
    BookingsRepository? bookingsRepository,
    FavoritesRepository? favoritesRepository,
    NotificationsRepository? notificationsRepository,
    ChatRepository? chatRepository,
  })  : servicesRepository = servicesRepository ?? ServicesRepositoryImpl(),
        bookingsRepository = bookingsRepository ?? BookingsRepositoryImpl(),
        favoritesRepository = favoritesRepository ?? FavoritesRepositoryImpl(),
        notificationsRepository =
            notificationsRepository ?? NotificationsRepositoryImpl(),
        chatRepository = chatRepository ?? ChatRepositoryImpl();

  // ── USERS ─────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final data = await ApiClient.get(ApiEndpoints.me, auth: true);
      return data['user'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateUserData({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await ApiClient.put(ApiEndpoints.updateProfile, body: data, auth: true);
  }

  // ── SERVICES ──────────────────────────────────────────────
  Future<List<ServiceModel>> getServices({String? category}) =>
      servicesRepository.getServices(category: category);

  Future<List<ServiceModel>> getPopularServices() =>
      servicesRepository.getPopularServices();

  Future<List<ServiceModel>> searchServices(String query, String category) =>
      servicesRepository.searchServices(query, category);

  Future<ServiceModel?> getServiceById(String id) =>
      servicesRepository.getServiceById(id);

  Future<List<String>> getCategories() =>
      servicesRepository.getCategories();

  Future<List<Map<String, dynamic>>> getSliders() =>
      servicesRepository.getSliders();

  // ── BOOKINGS ──────────────────────────────────────────────
  Future<List<BookingModel>> getUserBookings() =>
      bookingsRepository.getUserBookings();

  Future<BookingModel> createBooking({
    required String serviceName,
    required String date,
    required String time,
    required double price,
    String? serviceId,
    String? userId,
    String? status,
    String serviceImageUrl = '',
    String location = '',
    String clientName = '',
    String clientPhone = '',
    double? latitude,
    double? longitude,
    String paymentMethod = '',
    String therapistName = '',
    String? notes,
  }) =>
      bookingsRepository.createBooking(
        serviceName: serviceName,
        date: date,
        time: time,
        price: price,
        serviceId: serviceId,
        userId: userId,
        status: status,
        serviceImageUrl: serviceImageUrl,
        location: location,
        clientName: clientName,
        clientPhone: clientPhone,
        latitude: latitude,
        longitude: longitude,
        paymentMethod: paymentMethod,
        therapistName: therapistName,
        notes: notes,
      );

  Future<bool> checkTimeSlotAvailable(String date, String time) =>
      bookingsRepository.checkTimeSlotAvailable(date, time);

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) =>
      bookingsRepository.updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );

  Future<void> confirmPayment(String bookingId) =>
      bookingsRepository.confirmPayment(bookingId);

  Future<void> requestCancelBooking(String bookingId) =>
      bookingsRepository.requestCancelBooking(bookingId);

  // ── FAVORITES ─────────────────────────────────────────────
  Future<void> toggleFavorite(String userId, String serviceId) =>
      favoritesRepository.toggleFavorite(serviceId);

  Future<bool> isFavorite(String userId, String serviceId) =>
      favoritesRepository.isFavorite(serviceId);

  Future<List<String>> getFavoriteIds(String userId) =>
      favoritesRepository.getFavoriteIds();

  Future<List<ServiceModel>> getFavoriteServices(String userId) =>
      favoritesRepository.getFavoriteServices();

  // ── NOTIFICATIONS ─────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getNotifications([String? userId]) =>
      notificationsRepository.getNotifications();

  Future<void> markNotificationAsRead(String notifId, {String? userId}) =>
      notificationsRepository.markAsRead(notifId);

  Future<void> markAllNotificationsAsRead() =>
      notificationsRepository.markAllAsRead();

  // ── CHAT & SUPPORT ────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getMessages(String userId) =>
      chatRepository.getMessages();

  Future<void> sendMessage({
    required String userId,
    required String text,
    required bool isAdmin,
    String? userName,
  }) =>
      chatRepository.sendMessage(
        text: text,
        isAdmin: isAdmin,
        userName: userName,
      );

  Future<void> createSupportRequest({
    required String userId,
    required String bookingId,
    required String message,
  }) =>
      chatRepository.createSupportRequest(
        userId: userId,
        bookingId: bookingId,
        message: message,
      );
}

typedef FirestoreService = DataService;
