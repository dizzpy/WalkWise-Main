import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../services/place_service.dart';

class PlaceProvider extends ChangeNotifier {
  final PlaceService _placeService = PlaceService();
  List<PlaceModel> _places = [];
  bool _loading = false;

  List<PlaceModel> get places => _places;
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
