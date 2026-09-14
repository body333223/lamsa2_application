import '../../../../models/booking_model.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../datasources/bookings_remote_datasource.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  final BookingsRemoteDataSource remoteDataSource;

  BookingsRepositoryImpl({BookingsRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? BookingsRemoteDataSourceImpl();

  @override
  Future<List<BookingModel>> getUserBookings() =>
      remoteDataSource.getUserBookings();

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
  }) =>
      remoteDataSource.createBooking(
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

  @override
  Future<bool> checkTimeSlotAvailable(String date, String time) =>
      remoteDataSource.checkTimeSlotAvailable(date, time);

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) =>
      remoteDataSource.updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );

  @override
  Future<void> confirmPayment(String bookingId) =>
      remoteDataSource.confirmPayment(bookingId);

  @override
  Future<void> requestCancelBooking(String bookingId) =>
      remoteDataSource.requestCancelBooking(bookingId);
}
