import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role; // Add role field
  final String profileImgLink;
  final DateTime? createdAt;
  final List<String> interests;
  final String location;
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.role = 'user', // Default role
    this.profileImgLink = '',
    this.createdAt,
    this.interests = const [],
    this.location = 'New York, USA',
    this.latitude,
    this.longitude,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user', // Add role from json
      profileImgLink: json['profileImgLink'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      interests: List<String>.from(json['interests'] ?? []),
      location: json['location'] ?? 'New York, USA',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? role,
    String? profileImgLink,
    DateTime? createdAt,
    List<String>? interests,
    String? location,
    double? latitude,
    double? longitude,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImgLink: profileImgLink ?? this.profileImgLink,
      createdAt: createdAt ?? this.createdAt,
      interests: interests ?? this.interests,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role, // Add role to json
      'profileImgLink': profileImgLink,
      'createdAt': createdAt?.toIso8601String(),
      'interests': interests,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
