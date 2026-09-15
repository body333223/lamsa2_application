import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../models/service_model.dart';

abstract class ServicesRemoteDataSource {
  Future<List<ServiceModel>> getServices({String? category});
  Future<List<ServiceModel>> getPopularServices();
  Future<List<ServiceModel>> searchServices(String query, String category);
  Future<ServiceModel?> getServiceById(String id);
  Future<List<String>> getCategories();
  Future<List<Map<String, dynamic>>> getSliders();
}

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  // ── Mock Fallback Data ──────────────────────────────────────
  static final List<ServiceModel> _fallbackServices = [
    const ServiceModel(
      id: 'srv_1',
      name: 'مساج سويدي استرخائي',
      description: 'جلسة مساج متكاملة بأجود الزيوت الطبيعية تساعد على الاسترخاء وتخفيف التوتر وإعادة الحيوية للجسم.',
      price: 250.0,
      durationMinutes: 60,
      imageUrl: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=800&auto=format&fit=crop',
      category: 'مساج',
      rating: 4.9,
      reviewCount: 128,
      isPopular: true,
    ),
    const ServiceModel(
      id: 'srv_2',
      name: 'حمام مغربي ملكي بالأعشاب',
      description: 'تجربة ملكية متكاملة بالصابون البلدي المغربي والطمي والأعشاب الطبيعية مع تقشير وترطيب عميق للبشرة.',
      price: 320.0,
      durationMinutes: 75,
      imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800&auto=format&fit=crop',
      category: 'حمام مغربي',
      rating: 4.95,
      reviewCount: 94,
      isPopular: true,
    ),
    const ServiceModel(
      id: 'srv_3',
      name: 'تنظيف بشرة عميق هيدرافاشيل',
      description: 'جلسة تنظيف وتغذية عميقة للبشرة باستخدام أحدث التقنيات لإزالة الرؤوس السوداء وإعادة النضارة والإشراق.',
      price: 280.0,
      durationMinutes: 60,
      imageUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=800&auto=format&fit=crop',
      category: 'عناية بالبشرة',
      rating: 4.85,
      reviewCount: 76,
      isPopular: true,
    ),
    const ServiceModel(
      id: 'srv_4',
      name: 'بادكير ومنكير سبا متكامل',
      description: 'عناية فائقة بالأظافر واليدين والقدمين مع تقشير وترطيب ومساج وماسك البرافين المغذي.',
      price: 180.0,
      durationMinutes: 45,
      imageUrl: 'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=800&auto=format&fit=crop',
      category: 'بادكير ومنكير',
      rating: 4.8,
      reviewCount: 110,
      isPopular: true,
    ),
    const ServiceModel(
      id: 'srv_5',
      name: 'استشوار وتسريحة ويفي احترافية',
      description: 'تصفيف وتصفيف الشعر بأحدث الأجهزة مع سيروم الحماية من الحرارة لإطلالة مميزة ولامعة.',
      price: 150.0,
      durationMinutes: 45,
      imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800&auto=format&fit=crop',
      category: 'شعر',
      rating: 4.75,
      reviewCount: 65,
      isPopular: false,
    ),
    const ServiceModel(
      id: 'srv_6',
      name: 'مساج الأحجار الساخنة',
      description: 'مساج علاجي بالأحجار البركانية الدافئة والزيوت العطرية لتخفيف آلام العضلات وتنشيط الدورة الدموية.',
      price: 300.0,
      durationMinutes: 75,
      imageUrl: 'https://images.unsplash.com/photo-1600334129128-685c5582fd35?w=800&auto=format&fit=crop',
      category: 'مساج',
      rating: 4.92,
      reviewCount: 88,
      isPopular: true,
    ),
  ];

  static final List<String> _fallbackCategories = [
    'الكل',
    'مساج',
    'حمام مغربي',
    'عناية بالبشرة',
    'بادكير ومنكير',
    'شعر',
  ];

  static final List<Map<String, dynamic>> _fallbackSliders = [
    {
      'id': 'slider_1',
      'title': 'خدمات سبا منزلية فاخرة',
      'subtitle': 'احجزي جلستك واستمتعي بالراحة في منزلك',
      'image_url': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=1200&auto=format&fit=crop',
      'tag': 'عرض خاص',
    },
    {
      'id': 'slider_2',
      'title': 'باقات العناية المتكاملة',
      'subtitle': 'خصم 20% على باقات الحمام المغربي والمساج',
      'image_url': 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=1200&auto=format&fit=crop',
      'tag': 'الأكثر طلباً',
    },
  ];

  @override
  Future<List<ServiceModel>> getServices({String? category}) async {
    try {
      final query = <String, String>{};
      if (category != null && category.isNotEmpty && category != 'الكل' && category != 'all') {
        query['category'] = category;
      }
      final data = await ApiClient.get(ApiEndpoints.services, query: query);
      final list = data['services'] as List<dynamic>? ?? [];
      final result = list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
      if (result.isNotEmpty) return result;
    } catch (_) {}

    // Fallback Mock Data
    if (category == null || category.isEmpty || category == 'الكل' || category == 'all') {
      return _fallbackServices;
    }
    return _fallbackServices.where((s) => s.category == category).toList();
  }

  @override
  Future<List<ServiceModel>> getPopularServices() async {
    try {
      final data = await ApiClient.get(ApiEndpoints.popularServices);
      final list = data['services'] as List<dynamic>? ?? [];
      final result = list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
      if (result.isNotEmpty) return result;
    } catch (_) {}

    // Fallback Mock Data
    return _fallbackServices.where((s) => s.isPopular).toList();
  }

  @override
  Future<List<ServiceModel>> searchServices(String query, String category) async {
    try {
      final data = await ApiClient.get(ApiEndpoints.searchServices, query: {
        'q': query,
        'category': category,
      });
      final list = data['services'] as List<dynamic>? ?? [];
      final result = list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
      if (result.isNotEmpty) return result;
    } catch (_) {}

    // Fallback Mock Search
    final q = query.toLowerCase().trim();
    return _fallbackServices.where((s) {
      final matchesQuery = q.isEmpty || s.name.toLowerCase().contains(q) || s.description.toLowerCase().contains(q);
      final matchesCategory = category.isEmpty || category == 'الكل' || category == 'all' || s.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Future<ServiceModel?> getServiceById(String id) async {
    try {
      final data = await ApiClient.get(ApiEndpoints.serviceById(id));
      return ServiceModel.fromJson(data['service'] as Map<String, dynamic>);
    } catch (_) {}

    try {
      return _fallbackServices.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final data = await ApiClient.get(ApiEndpoints.categories);
      final list = (data['categories'] as List<dynamic>? ?? []).cast<String>();
      if (list.isNotEmpty) return list;
    } catch (_) {}

    return _fallbackCategories;
  }

  @override
  Future<List<Map<String, dynamic>>> getSliders() async {
    try {
      final data = await ApiClient.get(ApiEndpoints.sliders);
      final list = (data['sliders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      if (list.isNotEmpty) return list;
    } catch (_) {}

    return _fallbackSliders;
  }
}
