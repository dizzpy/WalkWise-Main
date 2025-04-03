import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String placeId;
  final String placeName; // Add this field
  final String reportedBy;
  final String reason;
  final String details;
  final DateTime reportedAt;
  final String status; // pending, reviewed, resolved

  ReportModel({
    required this.id,
    required this.placeId,
    required this.placeName, // Add to constructor
    required this.reportedBy,
    required this.reason,
    required this.details,
    required this.reportedAt,
    this.status = 'pending',
  });

  factory ReportModel.fromJson(Map<String, dynamic> json, String id) {
    try {
      return ReportModel(
        id: id,
        placeId: json['placeId'] ?? '',
        placeName: json['placeName'] ?? 'Unknown Place', // Better fallback
        reportedBy: json['reportedBy'] ?? '',
        reason: json['reason'] ?? '',
        details: json['details'] ?? '',
        reportedAt:
            (json['reportedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        status: json['status'] ?? 'pending',
      );
    } catch (e) {
      print('Error parsing report model: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'placeName': placeName, // Add to toJson mapping
      'reportedBy': reportedBy,
      'reason': reason,
      'details': details,
      'reportedAt': Timestamp.fromDate(reportedAt),
      'status': status,
    };
  }
}
