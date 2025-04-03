import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? placeId;
  final String? userId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.placeId,
    this.userId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, String id) {
    try {
      print('Parsing notification data: $json'); // Debug print

      final notification = json['notification'] as Map<String, dynamic>? ?? {};
      final data = json['data'] as Map<String, dynamic>? ?? {};

      return NotificationModel(
        id: id,
        title: notification['title'] ?? 'New Notification',
        message: notification['body'] ?? '',
        createdAt:
            (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isRead: json['read'] ?? false,
        placeId: data['placeId'],
        userId: json['userId'],
      );
    } catch (e) {
      print('Error parsing notification: $e');
      rethrow;
    }
  }
}
