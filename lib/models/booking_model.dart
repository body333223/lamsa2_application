import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final String therapistName;
  final DateTime dateTime;
  final double price;
  final String status;
  final String location;
  final String? notes;
  final String serviceImageUrl;
  final String paymentMethod;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.therapistName,
    required this.dateTime,
    required this.price,
    required this.status,
    required this.location,
    this.notes,
    required this.serviceImageUrl,
    required this.paymentMethod,
  });

  BookingModel copyWith({
    String? id,
    String? userId,
    String? serviceId,
    String? serviceName,
    String? therapistName,
    DateTime? dateTime,
    double? price,
    String? status,
    String? location,
    String? notes,
    String? serviceImageUrl,
    String? paymentMethod,
  }) =>
      BookingModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        serviceId: serviceId ?? this.serviceId,
        serviceName: serviceName ?? this.serviceName,
        therapistName: therapistName ?? this.therapistName,
        dateTime: dateTime ?? this.dateTime,
        price: price ?? this.price,
        status: status ?? this.status,
        location: location ?? this.location,
        notes: notes ?? this.notes,
        serviceImageUrl: serviceImageUrl ?? this.serviceImageUrl,
        paymentMethod: paymentMethod ?? this.paymentMethod,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'therapistName': therapistName,
        'dateTime': Timestamp.fromDate(dateTime),
        'price': price,
        'status': status,
        'location': location,
        if (notes != null) 'notes': notes,
        'serviceImageUrl': serviceImageUrl,
        'paymentMethod': paymentMethod,
        'createdAt': FieldValue.serverTimestamp(),
      };

  static BookingModel fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    DateTime dt;
    final raw = d['dateTime'];
    if (raw is Timestamp) {
      dt = raw.toDate();
    } else {
      dt = DateTime.now();
    }
    return BookingModel(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      serviceId: d['serviceId'] as String? ?? '',
      serviceName: d['serviceName'] as String? ?? '',
      therapistName: d['therapistName'] as String? ?? '',
      dateTime: dt,
      price: (d['price'] as num?)?.toDouble() ?? 0,
      status: d['status'] as String? ?? 'pending',
      location: d['location'] as String? ?? 'المنزل',
      notes: d['notes'] as String?,
      serviceImageUrl: d['serviceImageUrl'] as String? ?? '',
      paymentMethod: d['paymentMethod'] as String? ?? '',
    );
  }

  static BookingModel fromJson(Map<String, dynamic> data, String id) {
    DateTime dt;
    final raw = data['dateTime'] ?? data['createdAt'];
    if (raw is Timestamp) {
      dt = raw.toDate();
    } else {
      dt = DateTime.now();
    }
    return BookingModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      serviceId: data['serviceId'] as String? ?? '',
      serviceName: data['serviceName'] as String? ?? '',
      therapistName: data['therapistName'] as String? ?? '',
      dateTime: dt,
      price: (data['price'] as num?)?.toDouble() ?? 0,
      status: data['status'] as String? ?? 'pending',
      location: data['location'] as String? ?? 'المنزل',
      notes: data['notes'] as String?,
      serviceImageUrl: data['serviceImageUrl'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String? ?? '',
    );
  }
}
