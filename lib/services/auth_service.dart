import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Login User
  Future<UserCredential> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

// Register User
  Future<UserCredential> register(
      String email, String password, String fullName) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document with role
      await _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'role': 'user', // Set default role
        'createdAt': FieldValue.serverTimestamp(),
        'profileImgLink': '',
        'interests': [],
        'location': '',
        'latitude': null,
        'longitude': null,
      });

      return userCredential;
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    }
  }

  // Create User Data in Firestore
  Future<void> createUserData({
    required String uid,
    required String email,
    required String fullName,
  }) async {
    try {
      print('Creating Firestore document for user: $email');
      final userDoc = _firestore.collection('Users').doc(uid);

      // Check if the document already exists
      final docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        print('Firestore document already exists for user: $email');
        return;
      }

      // Save user data
      await userDoc.set({
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'interests': [],
        'profileImgLink': '',
      });

      print('Firestore document created successfully for user: $email');
    } catch (e, stackTrace) {
      print('Error creating Firestore document for user: $email - $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to create user data: ${e.toString()}');
    }
  }

  // Handle FirebaseAuthException
  String _handleAuthError(FirebaseAuthException e) {
    print('Handling FirebaseAuthException: ${e.code} - ${e.message}');
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // Check if user is logged in
  Future<void> signOut() async {
    print('Signing out user');
    await _auth.signOut();
  }
}
