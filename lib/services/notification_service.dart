import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/place_model.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) async {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && newToken != null) {
          await saveUserToken(currentUser.uid);
        }
      });

      // Get initial token
      final token = await _fcm.getToken();
      print('FCM Token: $token');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> saveUserToken(String userId) async {
    try {
      String? token = await _fcm.getToken();
      print('Saving token for user $userId: $token');

      if (token != null) {
        await _firestore.collection('Users').doc(userId).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  String _formatAddress(String fullAddress) {
    // Split the address by commas and clean up
    final parts = fullAddress.split(',').map((s) => s.trim()).toList();

    // Try to get the most relevant part (usually city or junction name)
    String locationName = '';
    if (parts.length > 1) {
      // Look for parts that don't contain common words like "Road", "Province", etc.
      locationName = parts.firstWhere(
        (part) =>
            !part.toLowerCase().contains('road') &&
            !part.toLowerCase().contains('province') &&
            !part.toLowerCase().contains('district') &&
            !part.contains('-') &&
            part.length < 30,
        orElse: () => parts[1], // Fallback to second part if no match
      );
    } else {
      locationName = parts.first;
    }

    return locationName;
  }

  Future<void> notifyNewPlace(PlaceModel place, String addedById) async {
    try {
      // First get the user's full name
      final userDoc = await _firestore.collection('Users').doc(addedById).get();
      final addedByName = userDoc.data()?['fullName'] ?? 'Someone';

      final locationName = _formatAddress(place.address);
      final tagString = place.tags.isNotEmpty
          ? ' #${place.tags.take(2).join(" #")}${place.tags.length > 2 ? "..." : ""}'
          : '';

      final usersSnapshot = await _firestore.collection('Users').get();

      for (var doc in usersSnapshot.docs) {
        await _firestore.collection('notifications').add({
          'userId': doc.id,
          'notification': {
            'title': '📍 New Place Added',
            'body':
                '$addedByName added ${place.name} near $locationName$tagString',
          },
          'data': {
            'placeId': place.id,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
          'addedBy': addedByName,
          'placeName': place.name,
          'placeLocation': locationName,
          'placeTags': place.tags,
        });
      }
    } catch (e) {
      print('Error sending notifications: $e');
      rethrow;
    }
  }

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      print('Fetching notifications for user: $userId');

      // Simple query while index is building
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      print('Found ${snapshot.docs.length} notifications');

      final notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Processing notification ${doc.id}: $data');
        return NotificationModel.fromJson(data, doc.id);
      }).toList();

      // Sort locally until index is ready
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications;
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }
}
