import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();
  UserModel? _user;
  bool _loading = false;

  UserModel? get user => _user;
  bool get loading => _loading;

  Future<void> loadUser() async {
    _loading = true;
    notifyListeners();

    try {
      _user = await _userService.getCurrentUser();
      if (_user != null) {
        await _notificationService.saveUserToken(_user!.id);
      }
    } catch (e) {
      print('Error loading user: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _loading = true;
    notifyListeners();

    try {
      await _userService.logout();
      _user = null;
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> updateLocation(
      String location, double latitude, double longitude) async {
    try {
      _loading = true;
      notifyListeners();

      await _userService.updateLocation(
          _user!.id, location, latitude, longitude);
      _user = _user?.copyWith(
        location: location,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      print('Error updating location: $e');
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
