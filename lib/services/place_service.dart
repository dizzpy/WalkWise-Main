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
}
