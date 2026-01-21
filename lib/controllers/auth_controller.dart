import 'package:flutter/foundation.dart';
import '../core/models/client.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  Client? _currentUser;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Client? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isUser => _currentUser?.isUser ?? false;
  int? get currentUserId => _currentUser?.id;

  Future<bool> login(String emailOrUsername, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.login(emailOrUsername, password);
      await _loadCurrentUser();
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String passportNumber,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signup(
        email: email,
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
        passportNumber: passportNumber,
        phone: phone,
        address: address,
      );
      await _loadCurrentUser();
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadCurrentUser();
      _isAuthenticated = _currentUser != null;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = await _authService.getCurrentUser();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

