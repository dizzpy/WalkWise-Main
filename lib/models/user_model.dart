import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String profileImgLink;
  final DateTime? createdAt;
  final List<String> interests;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.profileImgLink = '',
    this.createdAt,
    this.interests = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      profileImgLink: json['profileImgLink'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      interests: List<String>.from(json['interests'] ?? []),
    );
  }
}
