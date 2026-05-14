import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/service_model.dart';

/// Repository that handles all Firestore data fetching for the Home feature.
class HomeRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream of all services from Firestore.
  Stream<List<ServiceModel>> getServices() {
    return _db.collection('services').snapshots().map(
          (snap) =>
              snap.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList(),
        );
  }

  /// Stream of popular/featured services.
  Stream<List<ServiceModel>> getPopularServices() {
    return _db
        .collection('services')
        .where('isPopular', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList());
  }

  /// Stream of active slider/promo banners.
  Stream<QuerySnapshot> getActiveSliders() {
    return _db
        .collection('sliders')
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  /// Stream of service categories.
  Stream<List<String>> getCategories() {
    return _db.collection('categories').snapshots().map(
          (snap) => snap.docs.map((doc) => doc['name'] as String).toList(),
        );
  }

  /// Get user data by userId.
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data();
  }
}
