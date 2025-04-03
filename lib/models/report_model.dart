import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String placeId;
  final String reportedBy;
  final String reason;
  final String details;
  final DateTime reportedAt;
  final String status; // pending, reviewed, resolved

  ReportModel({
    required this.id,
    required this.placeId,
    required this.reportedBy,
    required this.reason,
    required this.details,
    required this.reportedAt,
    this.status = 'pending',
  });

  factory ReportModel.fromJson(Map<String, dynamic> json, String id) {
    return ReportModel(
      id: id,
      placeId: json['placeId'] ?? '',
      reportedBy: json['reportedBy'] ?? '',
      reason: json['reason'] ?? '',
      details: json['details'] ?? '',
      reportedAt: (json['reportedAt'] as Timestamp).toDate(),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'reportedBy': reportedBy,
      'reason': reason,
      'details': details,
      'reportedAt': Timestamp.fromDate(reportedAt),
      'status': status,
    };
  }
}
