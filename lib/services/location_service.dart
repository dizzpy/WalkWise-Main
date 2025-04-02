import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String nominatimUrl =
      'https://nominatim.openstreetmap.org/search';

  Future<List<Place>> searchPlaces(String query) async {
    if (query.length < 3) return [];

    final response = await http.get(
      Uri.parse('$nominatimUrl?q=$query&format=json&limit=5'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List places = json.decode(response.body);
      return places.map((place) => Place.fromJson(place)).toList();
    }
    return [];
  }
}

class Place {
  final String displayName;
  final String lat;
  final String lon;

  Place({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      displayName: json['display_name'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}
