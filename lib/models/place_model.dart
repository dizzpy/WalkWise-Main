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
  int reviewCount;

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
    this.reviewCount = 0,
  });

  // Add copyWith method
  PlaceModel copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    List<String>? tags,
    String? addedBy,
    DateTime? addedDate,
    String? address,
    int? reviewCount,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tags: tags ?? this.tags,
      addedBy: addedBy ?? this.addedBy,
      addedDate: addedDate ?? this.addedDate,
      address: address ?? this.address,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

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
      'reviewCount': reviewCount,
    };
  }

  factory PlaceModel.fromJson(Map<String, dynamic> json, String id) {
    return PlaceModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      addedBy: json['addedBy'] ?? '',
      addedDate: (json['addedDate'] as Timestamp).toDate(),
      address: json['address'] ?? '',
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}
