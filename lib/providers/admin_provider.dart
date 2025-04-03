import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserModel> _users = [];
  List<PlaceModel> _places = [];
  List<ReportModel> _reportedPlaces = [];
  bool _loading = false;

  List<UserModel> get users => _users;
  List<PlaceModel> get places => _places;
  List<ReportModel> get reportedPlaces => _reportedPlaces;
  bool get loading => _loading;

  int get userCount => _users.length;
  int get placeCount => _places.length;
  int get reportCount => _reportedPlaces.length;
  int get reviewCount =>
      _places.fold(0, (sum, place) => sum + place.reviewCount);

  Future<void> loadDashboardData() async {
    if (_loading) return; // Prevent multiple calls

    _loading = true;

    // Use microtask to delay notifyListeners() until after the build phase
    Future.microtask(() => notifyListeners());

    try {
      await Future.wait([
        loadUsers(),
        loadPlaces(),
        loadReportedPlaces(),
      ]);
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      _loading = false;

      // Again, use microtask to ensure state changes after build phase
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> loadUsers() async {
    try {
      final snapshot = await _firestore.collection('Users').get();
      final newUsers = snapshot.docs
          .map((doc) => UserModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      _users = newUsers;
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> loadPlaces() async {
    try {
      final snapshot = await _firestore.collection('places').get();
      final newPlaces = snapshot.docs
          .map((doc) => PlaceModel.fromJson(doc.data(), doc.id))
          .toList();

      _places = newPlaces;
    } catch (e) {
      print('Error loading places: $e');
    }
  }

  Future<void> loadReportedPlaces() async {
    try {
      final snapshot = await _firestore
          .collection('reportedPlaces')
          .where('status', isEqualTo: 'pending')
          .get();

      _reportedPlaces = [];

      for (var doc in snapshot.docs) {
        final reportData = doc.data();
        // Fetch place details
        final placeDoc = await _firestore
            .collection('places')
            .doc(reportData['placeId'])
            .get();

        if (placeDoc.exists) {
          final placeData = placeDoc.data()!;
          reportData['placeName'] = placeData['name']; // Add place name
          _reportedPlaces.add(ReportModel.fromJson(reportData, doc.id));
        }
      }
    } catch (e) {
      print('Error loading reported places: $e');
    }
  }

  Future<void> resolveReport(String reportId) async {
    try {
      await _firestore
          .collection('reportedPlaces')
          .doc(reportId)
          .update({'status': 'resolved'});

      // Remove from local list
      _reportedPlaces.removeWhere((report) => report.id == reportId);
      notifyListeners();
    } catch (e) {
      print('Error resolving report: $e');
      rethrow;
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      // Get the report data before deleting
      final reportDoc =
          await _firestore.collection('reportedPlaces').doc(reportId).get();
      if (!reportDoc.exists) {
        throw Exception('Report not found');
      }

      final reportData = reportDoc.data()!;
      final String placeId = reportData['placeId'];

      // Start a batch write
      final batch = _firestore.batch();

      // Delete the report
      batch.delete(_firestore.collection('reportedPlaces').doc(reportId));

      // Delete the place
      batch.delete(_firestore.collection('places').doc(placeId));

      // Get all reviews for this place
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('placeId', isEqualTo: placeId)
          .get();

      // Delete all reviews
      for (var doc in reviewsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Get all notifications related to this place
      final notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('data.placeId', isEqualTo: placeId)
          .get();

      // Delete all related notifications
      for (var doc in notificationsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();

      // Update local state
      _reportedPlaces.removeWhere((report) => report.id == reportId);
      _places.removeWhere((place) => place.id == placeId);
      notifyListeners();
    } catch (e) {
      print('Error deleting report and related data: $e');
      rethrow;
    }
  }
}
