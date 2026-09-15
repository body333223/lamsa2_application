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
  static final List<BookingModel> _localBookings = [];

  @override
  Future<List<BookingModel>> getUserBookings() async {
    try {
      final data = await ApiClient.get(ApiEndpoints.bookings, auth: true);
      final list = data['bookings'] as List<dynamic>? ?? [];
      final result = list.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
      return result;
    } catch (_) {
      return List.unmodifiable(_localBookings.reversed);
    }
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

    try {
      final data = await ApiClient.post(ApiEndpoints.bookings, body: body, auth: true);
      final booking = BookingModel.fromJson(data['booking'] as Map<String, dynamic>);
      _localBookings.add(booking);
      return booking;
    } catch (_) {
      DateTime dt;
      try {
        dt = DateTime.tryParse('${date}T$time') ?? DateTime.now();
      } catch (_) {
        dt = DateTime.now();
      }

      final mockBooking = BookingModel(
        id: 'book_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId ?? 'mock_user',
        serviceId: serviceId ?? 'srv_1',
        serviceName: serviceName,
        date: date,
        time: time,
        dateTime: dt,
        price: price,
        status: status ?? 'مؤكد',
        serviceImageUrl: serviceImageUrl.isNotEmpty
            ? serviceImageUrl
            : 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=800&auto=format&fit=crop',
        location: location.isNotEmpty ? location : 'الرياض - حي النرجس',
        clientName: clientName,
        clientPhone: clientPhone,
        paymentMethod: paymentMethod.isNotEmpty ? paymentMethod : 'بطاقة ائتمان',
        therapistName: therapistName.isNotEmpty ? therapistName : 'سارة أحمد (أخصائية معتمدة)',
        notes: notes,
      );
      _localBookings.add(mockBooking);
      return mockBooking;
    }
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
    try {
      await ApiClient.patch(ApiEndpoints.bookingStatus(bookingId),
          body: {'status': status}, auth: true);
    } catch (_) {}

    final index = _localBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _localBookings[index] = _localBookings[index].copyWith(status: status);
    }
  }

  @override
  Future<void> confirmPayment(String bookingId) async {
    try {
      await ApiClient.post(ApiEndpoints.confirmPayment(bookingId), auth: true);
    } catch (_) {}
    await updateBookingStatus(bookingId: bookingId, status: 'مؤكد');
  }

  @override
  Future<void> requestCancelBooking(String bookingId) async {
    try {
      await ApiClient.post(ApiEndpoints.cancelBooking(bookingId), auth: true);
    } catch (_) {}
    await updateBookingStatus(bookingId: bookingId, status: 'ملغي');
  }
}
