import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceModel {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> tags;
  final String addedBy;
  final DateTime addedDate;
  final String address;

  PlaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.tags,
    required this.addedBy,
    required this.addedDate,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags,
      'addedBy': addedBy,
      'addedDate': Timestamp.fromDate(addedDate),
      'address': address,
    };
  }

  factory PlaceModel.fromJson(Map<String, dynamic> json, String id) {
    return PlaceModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      tags: List<String>.from(json['tags'] ?? []),
      addedBy: json['addedBy'] ?? '',
      addedDate: (json['addedDate'] as Timestamp).toDate(),
      address: json['address'] ?? '',
    );
  }
}
