import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../services/place_service.dart';

class PlaceProvider extends ChangeNotifier {
  final PlaceService _placeService = PlaceService();
  List<PlaceModel> _places = [];
  List<PlaceModel> _lastViewedPlaces = [];
  bool _loading = false;

  List<PlaceModel> get places => _places;
  List<PlaceModel> get lastViewedPlaces => _lastViewedPlaces;
  bool get loading => _loading;

  Future<void> loadPlaces() async {
    _loading = true;
    notifyListeners();

    try {
      _places = await _placeService.getPlaces();
    } catch (e) {
      print('Error loading places: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadLastViewedPlaces(String userId) async {
    try {
      _lastViewedPlaces = await _placeService.getLastViewedPlaces(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading last viewed places: $e');
      _lastViewedPlaces = [];
      notifyListeners();
    }
  }

  Future<void> addToLastViewed(String userId, String placeId) async {
    try {
      // Remove if exists (to move to front)
      _lastViewedPlaces.removeWhere((p) => p.id == placeId);

      // Add to the beginning of the list
      final place = _places.firstWhere((p) => p.id == placeId);
      _lastViewedPlaces.insert(0, place);

      await _placeService.addToLastViewed(userId, placeId);
      notifyListeners();
    } catch (e) {
      print('Error adding to last viewed: $e');
    }
  }

  Future<void> addPlace(PlaceModel place) async {
    _loading = true;
    notifyListeners();

    try {
      final placeId = await _placeService.addPlace(place);
      final newPlace = PlaceModel(
        id: placeId,
        name: place.name,
        description: place.description,
        latitude: place.latitude,
        longitude: place.longitude,
        tags: place.tags,
        addedBy: place.addedBy,
        addedDate: place.addedDate,
        address: place.address,
      );
      _places.add(newPlace);
    } catch (e) {
      print('Error adding place: $e');
      rethrow;
    }

    _loading = false;
    notifyListeners();
  }
}
