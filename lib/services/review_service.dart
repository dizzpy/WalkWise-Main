import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ReviewModel>> getPlaceReviews(String placeId) async {
    try {
      print('Fetching reviews for place ID: $placeId'); // Debug print

      final snapshot = await _firestore
          .collection('reviews')
          .where('placeId', isEqualTo: placeId)
          .get();

      print('Found ${snapshot.size} reviews'); // Debug print

      final reviews = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Review document data: $data'); // Debug print
        return ReviewModel.fromJson(data, doc.id);
      }).toList();

      // Sort by createdAt descending
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return reviews;
    } catch (e) {
      print('Error getting reviews: $e');
      return [];
    }
  }

  Future<void> addReview({
    required String placeId,
    required String userId,
    required String userFullName,
    required String review,
    required int rating,
  }) async {
    try {
      await _firestore.collection('reviews').add({
        'placeId': placeId,
        'userId': userId,
        'userFullName': userFullName,
        'review': review,
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }

  Future<bool> hasUserReviewed(String placeId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('placeId', isEqualTo: placeId)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user review: $e');
      return false;
    }
  }
}
