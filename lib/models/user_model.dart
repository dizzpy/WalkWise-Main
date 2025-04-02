import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String profileImgLink;
  final DateTime? createdAt;
  final List<String> interests;
  final String location;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.profileImgLink = '',
    this.createdAt,
    this.interests = const [],
    this.location = 'New York, USA',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      profileImgLink: json['profileImgLink'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      interests: List<String>.from(json['interests'] ?? []),
      location: json['location'] ?? 'New York, USA',
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? profileImgLink,
    DateTime? createdAt,
    List<String>? interests,
    String? location,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profileImgLink: profileImgLink ?? this.profileImgLink,
      createdAt: createdAt ?? this.createdAt,
      interests: interests ?? this.interests,
      location: location ?? this.location,
    );
  }
}
