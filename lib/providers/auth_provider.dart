import 'package:flutter/material.dart';
import 'package:walkwise/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

// Login User
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.loginWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

// Register User
  Future<bool> register(String email, String password, String fullName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Starting registration for user: $email');
      final userCredential = await _authService.registerWithEmailAndPassword(
          email, password, fullName);

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid; // Fetch UID
        print('FirebaseAuth user created successfully for: $email (UID: $uid)');

        print('Attempting to create Firestore document for user: $email');
        await _authService.createUserData(
          uid: uid, // Use UID
          email: email,
          fullName: fullName,
        );
      }

      print('Registration and Firestore data creation successful for: $email');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('Registration error for user: $email - $e');
      print('Stack trace: $stackTrace');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

// Logout User
  Future<bool> logout() async {
    try {
      await _authService.signOut();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
