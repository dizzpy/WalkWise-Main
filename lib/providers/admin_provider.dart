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
}
