import 'dart:convert';
import 'dart:math';
import '../core/models/client.dart';
import '../core/database/database_helper.dart';
import '../core/services/token_storage_service.dart';
import '../data/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repository = AuthRepository();
  final TokenStorageService _tokenStorage = TokenStorageService();

  String _generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return base64Encode(bytes);
  }

  bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  Future<String> login(String emailOrUsername, String password) async {
    final user = await _repository.getByEmailOrUsername(emailOrUsername);
    
    if (user == null) {
      throw Exception('Invalid email/username or password');
    }

    if (!_verifyPassword(password, user.password)) {
      throw Exception('Invalid email/username or password');
    }

    // Generate and save token
    final token = _generateToken();
    await _repository.updateToken(user.id!, token);
    await _tokenStorage.saveToken(token);

    return token;
  }

  Future<String> signup({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String passportNumber,
    String? phone,
    String? address,
  }) async {
    // Check if email already exists
    final existingEmail = await _repository.getByEmail(email);
    if (existingEmail != null) {
      throw Exception('Email already registered');
    }

    // Check if username already exists
    final existingUsername = await _repository.getByUsername(username);
    if (existingUsername != null) {
      throw Exception('Username already taken');
    }

    // Note: Passport uniqueness is checked at database level

    // Create new user
    final now = DatabaseHelper.getCurrentTimestamp();
    final hashedPassword = _hashPassword(password);
    final token = _generateToken();

    final client = Client(
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: username,
      password: hashedPassword,
      role: 'user',
      authToken: token,
      passportNumber: passportNumber,
      phone: phone,
      address: address,
      createdAt: now,
      updatedAt: now,
    );

    final userId = await _repository.create(client);
    
    // Save token
    await _tokenStorage.saveToken(token);

    return token;
  }

  Future<void> logout() async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      final user = await _repository.getByToken(token);
      if (user != null) {
        await _repository.updateToken(user.id!, null);
      }
    }
    await _tokenStorage.clearToken();
  }

  Future<Client?> getCurrentUser() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return null;
    
    return await _repository.getByToken(token);
  }

  Future<bool> validateToken(String token) async {
    final user = await _repository.getByToken(token);
    return user != null;
  }
}

