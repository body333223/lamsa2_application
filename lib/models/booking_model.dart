class BookingModel {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final String therapistName;
  final DateTime dateTime;
  final String date;
  final String time;
  final double price;
  final String status;
  final String paymentStatus;
  final String location;
  final String? notes;
  final String serviceImageUrl;
  final String paymentMethod;
  final String clientName;
  final String clientPhone;

  const BookingModel({
    required this.id,
    required this.userId,
    this.serviceId = '',
    required this.serviceName,
    this.therapistName = '',
    required this.dateTime,
    this.date = '',
    this.time = '',
    required this.price,
    required this.status,
    this.paymentStatus = 'pending',
    required this.location,
    this.notes,
    required this.serviceImageUrl,
    this.paymentMethod = '',
    this.clientName = '',
    this.clientPhone = '',
  });

  BookingModel copyWith({
    String? id,
    String? userId,
    String? serviceId,
    String? serviceName,
    String? therapistName,
    DateTime? dateTime,
    String? date,
    String? time,
    double? price,
    String? status,
    String? paymentStatus,
    String? location,
    String? notes,
    String? serviceImageUrl,
    String? paymentMethod,
    String? clientName,
    String? clientPhone,
  }) =>
      BookingModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        serviceId: serviceId ?? this.serviceId,
        serviceName: serviceName ?? this.serviceName,
        therapistName: therapistName ?? this.therapistName,
        dateTime: dateTime ?? this.dateTime,
        date: date ?? this.date,
        time: time ?? this.time,
        price: price ?? this.price,
        status: status ?? this.status,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        location: location ?? this.location,
        notes: notes ?? this.notes,
        serviceImageUrl: serviceImageUrl ?? this.serviceImageUrl,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        clientName: clientName ?? this.clientName,
        clientPhone: clientPhone ?? this.clientPhone,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'service_id': serviceId,
        'service_name': serviceName,
        'therapist_name': therapistName,
        'date': date,
        'time': time,
        'price': price,
        'status': status,
        'payment_status': paymentStatus,
        'location': location,
        if (notes != null) 'notes': notes,
        'service_image_url': serviceImageUrl,
        'payment_method': paymentMethod,
        'client_name': clientName,
        'client_phone': clientPhone,
      };

  factory BookingModel.fromJson(Map<String, dynamic> data, [String? idOverride]) {
    final id = idOverride ?? data['id']?.toString() ?? '';

    // Parse dateTime from date + time or date_time field
    DateTime dt;
    final rawDatetime = data['date_time'];
    final rawDate = data['date']?.toString() ?? data['booking_date']?.toString() ?? '';
    final rawTime = data['time']?.toString() ?? data['booking_time']?.toString() ?? '';

    if (rawDatetime != null) {
      dt = DateTime.tryParse(rawDatetime.toString()) ?? DateTime.now();
    } else if (rawDate.isNotEmpty) {
      dt = DateTime.tryParse('$rawDate${rawTime.isNotEmpty ? 'T$rawTime' : ''}') ??
          DateTime.now();
    } else {
      dt = DateTime.now();
    }

    return BookingModel(
      id: id,
      userId: data['user_id']?.toString() ?? data['userId']?.toString() ?? '',
      serviceId: data['service_id']?.toString() ?? data['serviceId']?.toString() ?? '',
      serviceName: data['service_name']?.toString() ?? data['serviceName']?.toString() ?? '',
      therapistName: data['therapist_name']?.toString() ?? data['therapistName']?.toString() ?? '',
      dateTime: dt,
      date: rawDate,
      time: rawTime,
      price: (data['price'] as num?)?.toDouble() ?? (data['total_price'] as num?)?.toDouble() ?? 0,
      status: data['status']?.toString() ?? 'pending',
      paymentStatus: data['payment_status']?.toString() ?? data['paymentStatus']?.toString() ?? 'pending',
      location: data['location']?.toString() ?? data['address']?.toString() ?? '',
      notes: data['notes']?.toString(),
      serviceImageUrl: data['service_image_url']?.toString() ?? data['serviceImageUrl']?.toString() ?? '',
      paymentMethod: data['payment_method']?.toString() ?? data['paymentMethod']?.toString() ?? '',
      clientName: data['client_name']?.toString() ?? data['clientName']?.toString() ?? '',
      clientPhone: data['client_phone']?.toString() ?? data['clientPhone']?.toString() ?? '',
    );
  }
}
