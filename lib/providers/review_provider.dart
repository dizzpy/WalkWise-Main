import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _loading = false;
  String? _error;

  List<ReviewModel> get reviews => _reviews;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadReviews(String placeId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading reviews for place ID: $placeId'); // Debug print
      _reviews = await _reviewService.getPlaceReviews(placeId);
      print('Loaded ${_reviews.length} reviews'); // Debug print
    } catch (e) {
      print('Error in ReviewProvider.loadReviews: $e'); // Debug print
      _error = e.toString();
      _reviews = []; // Reset reviews on error
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addReview({
    required String placeId,
    required String userId,
    required String userFullName,
    required String review,
    required int rating,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _reviewService.addReview(
        placeId: placeId,
        userId: userId,
        userFullName: userFullName,
        review: review,
        rating: rating,
      );
      await loadReviews(placeId); // Reload reviews after adding
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteReview(String placeId, String reviewId) async {
    try {
      // Remove the review from local list first
      _reviews.removeWhere((review) => review.id == reviewId);
      notifyListeners();

      // Then delete from backend
      await _reviewService.deleteReview(reviewId);
    } catch (e) {
      // If deletion fails, reload reviews to restore state
      await loadReviews(placeId);
      throw e;
    }
  }

  Future<bool> hasUserReviewed(String placeId, String userId) async {
    try {
      return await _reviewService.hasUserReviewed(placeId, userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  double getAverageRating() {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold(0, (sum, review) => sum + review.rating);
    return total / _reviews.length;
  }

  void clearReviews() {
    _reviews = [];
    _error = null;
    notifyListeners();
  }
}
