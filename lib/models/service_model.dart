class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isPopular;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.isPopular,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['duration_minutes'] ?? json['durationMinutes'] as num?)?.toInt() ?? 0,
      imageUrl: (json['image_url'] ?? json['imageUrl'])?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] ?? json['reviewCount'] as num?)?.toInt() ?? 0,
      isPopular: json['is_popular'] == true || json['is_popular'] == 1 || json['isPopular'] == true || json['isPopular'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'duration_minutes': durationMinutes,
        'image_url': imageUrl,
        'category': category,
        'rating': rating,
        'review_count': reviewCount,
        'is_popular': isPopular,
      };
}