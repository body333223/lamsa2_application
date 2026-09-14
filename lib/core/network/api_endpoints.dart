/// Central registry of all backend REST API endpoints.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/me';

  // Services
  static const String services = '/services';
  static const String popularServices = '/services/popular';
  static const String searchServices = '/services/search';
  static const String categories = '/categories';
  static const String sliders = '/sliders';
  static String serviceById(String id) => '/services/$id';

  // Bookings
  static const String bookings = '/bookings';
  static const String checkTimeSlot = '/bookings/check-slot';
  static String bookingStatus(String id) => '/bookings/$id/status';
  static String confirmPayment(String id) => '/bookings/$id/confirm-payment';
  static String cancelBooking(String id) => '/bookings/$id/cancel';

  // Favorites
  static const String favorites = '/favorites';
  static const String favoriteIds = '/favorites/ids';
  static String toggleFavorite(String serviceId) => '/favorites/$serviceId/toggle';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // Support / Chat
  static const String chatMessages = '/chat/messages';
  static const String sendMessage = '/chat/messages';
  static const String supportRequest = '/support';

  // Upload
  static const String uploadAvatar = '/profile/avatar';
}
