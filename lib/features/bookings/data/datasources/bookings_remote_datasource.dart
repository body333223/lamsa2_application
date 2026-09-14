import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../models/booking_model.dart';

abstract class BookingsRemoteDataSource {
  Future<List<BookingModel>> getUserBookings();
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
  });
  Future<bool> checkTimeSlotAvailable(String date, String time);
  Future<void> updateBookingStatus({required String bookingId, required String status});
  Future<void> confirmPayment(String bookingId);
  Future<void> requestCancelBooking(String bookingId);
}

class BookingsRemoteDataSourceImpl implements BookingsRemoteDataSource {
  @override
  Future<List<BookingModel>> getUserBookings() async {
    final data = await ApiClient.get(ApiEndpoints.bookings, auth: true);
    final list = data['bookings'] as List<dynamic>? ?? [];
    return list.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
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
  }) async {
    final body = {
      'service_name': serviceName,
      'date': date,
      'time': time,
      'price': price,
      if (serviceId != null) 'service_id': serviceId,
      if (userId != null) 'user_id': userId,
      if (status != null) 'status': status,
      'service_image_url': serviceImageUrl,
      'location': location,
      'client_name': clientName,
      'client_phone': clientPhone,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'payment_method': paymentMethod,
      'therapist_name': therapistName,
      if (notes != null) 'notes': notes,
    };
    final data = await ApiClient.post(ApiEndpoints.bookings, body: body, auth: true);
    return BookingModel.fromJson(data['booking'] as Map<String, dynamic>);
  }

  @override
  Future<bool> checkTimeSlotAvailable(String date, String time) async {
    try {
      final data = await ApiClient.get(ApiEndpoints.checkTimeSlot, query: {
        'date': date,
        'time': time,
      });
      return data['available'] as bool? ?? true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    await ApiClient.patch(ApiEndpoints.bookingStatus(bookingId),
        body: {'status': status}, auth: true);
  }

  @override
  Future<void> confirmPayment(String bookingId) async {
    await ApiClient.post(ApiEndpoints.confirmPayment(bookingId), auth: true);
  }

  @override
  Future<void> requestCancelBooking(String bookingId) async {
    await ApiClient.post(ApiEndpoints.cancelBooking(bookingId), auth: true);
  }
}
