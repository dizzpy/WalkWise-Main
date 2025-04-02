import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Access the nested 'Users' collection and then the user document
        final doc = await _firestore.collection('Users').doc(user.uid).get();

        if (doc.exists) {
          print('User data found: ${doc.data()}'); // Debug print
          return UserModel.fromJson({
            'id': doc.id,
            ...doc.data()!,
          });
        } else {
          print('No user document found for ID: ${user.uid}'); // Debug print
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }
}
