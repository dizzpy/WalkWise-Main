import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place_model.dart';

class PlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addPlace(PlaceModel place) async {
    try {
      final docRef = await _firestore.collection('places').add(place.toJson());
      return docRef.id;
    } catch (e) {
      print('Error adding place: $e');
      rethrow;
    }
  }

  Future<List<PlaceModel>> getPlaces() async {
    try {
      final snapshot = await _firestore.collection('places').get();
      return snapshot.docs
          .map((doc) => PlaceModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting places: $e');
      return [];
    }
  }

  Future<List<PlaceModel>> getLastViewedPlaces(String userId) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(userId).get();
      final List<String> lastViewedIds =
          List<String>.from(userDoc.data()?['lastViewed'] ?? []);

      if (lastViewedIds.isEmpty) return [];

      // Reverse the list to get most recently viewed first
      lastViewedIds.reversed;

      final placesSnapshot = await _firestore
          .collection('places')
          .where(FieldPath.documentId, whereIn: lastViewedIds)
          .get();

      // Sort places based on the order in lastViewedIds
      final places = placesSnapshot.docs
          .map((doc) => PlaceModel.fromJson(doc.data(), doc.id))
          .toList();

      places.sort(
          (a, b) => lastViewedIds.indexOf(b.id) - lastViewedIds.indexOf(a.id));

      return places;
    } catch (e) {
      print('Error getting last viewed places: $e');
      return [];
    }
  }

  Future<void> addToLastViewed(String userId, String placeId) async {
    try {
      await _firestore.collection('Users').doc(userId).set({
        'lastViewed': FieldValue.arrayUnion([placeId])
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating last viewed: $e');
      rethrow;
    }
  }
}
