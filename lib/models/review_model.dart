import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String placeId;
  final String userId;
  final String userFullName;
  final String review;
  final int rating;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userFullName,
    required this.review,
    required this.rating,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json, String id) {
    try {
      print('Parsing review data - ID: $id, Data: $json'); // Debug print
      return ReviewModel(
        id: id,
        placeId: json['placeId'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        userFullName: json['userFullName'] as String? ?? '',
        review: json['review'] as String? ?? '',
        rating: json['rating'] as int? ?? 0,
        createdAt:
            (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      print('Error parsing review: $e'); // Debug print
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'userId': userId,
      'userFullName': userFullName,
      'review': review,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
