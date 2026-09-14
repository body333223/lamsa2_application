import '../../../../models/booking_model.dart';

abstract class BookingsRepository {
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
