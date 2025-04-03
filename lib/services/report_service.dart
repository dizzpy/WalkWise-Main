import 'package:cloud_firestore/cloud_firestore.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> reportReasons = [
    'Inappropriate content',
    'Incorrect information',
    'Place no longer exists',
    'Duplicate place',
    'Spam',
    'Other',
  ];

  Future<void> reportPlace({
    required String placeId,
    required String reportedBy,
    required String reason,
    required String details,
  }) async {
    try {
      await _firestore.collection('reportedPlaces').add({
        'placeId': placeId,
        'reportedBy': reportedBy,
        'reason': reason,
        'details': details,
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      print('Error reporting place: $e');
      rethrow;
    }
  }

  Future<bool> hasUserReportedPlace({
    required String placeId,
    required String userId,
  }) async {
    try {
      final reports = await _firestore
          .collection('reportedPlaces')
          .where('placeId', isEqualTo: placeId)
          .where('reportedBy', isEqualTo: userId)
          .get();

      return reports.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user reports: $e');
      return false;
    }
  }
}
