import '../database/database_constants.dart';

class Client {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String password;
  final String role;
  final String? authToken;
  final String passportNumber;
  final String? phone;
  final String? address;
  final String createdAt;
  final String updatedAt;

  Client({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.password,
    this.role = 'user',
    this.authToken,
    required this.passportNumber,
    this.phone,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';

  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.columnId: id,
      DatabaseConstants.columnClientFirstName: firstName,
      DatabaseConstants.columnClientLastName: lastName,
      DatabaseConstants.columnClientEmail: email,
      DatabaseConstants.columnClientUsername: username,
      DatabaseConstants.columnClientPassword: password,
      DatabaseConstants.columnClientRole: role,
      DatabaseConstants.columnClientAuthToken: authToken,
      DatabaseConstants.columnClientPassportNumber: passportNumber,
      DatabaseConstants.columnClientPhone: phone,
      DatabaseConstants.columnClientAddress: address,
      DatabaseConstants.columnCreatedAt: createdAt,
      DatabaseConstants.columnUpdatedAt: updatedAt,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map[DatabaseConstants.columnId] as int?,
      firstName: map[DatabaseConstants.columnClientFirstName] as String,
      lastName: map[DatabaseConstants.columnClientLastName] as String,
      email: map[DatabaseConstants.columnClientEmail] as String,
      username: map[DatabaseConstants.columnClientUsername] as String? ?? map[DatabaseConstants.columnClientEmail] as String,
      password: map[DatabaseConstants.columnClientPassword] as String? ?? '',
      role: map[DatabaseConstants.columnClientRole] as String? ?? 'user',
      authToken: map[DatabaseConstants.columnClientAuthToken] as String?,
      passportNumber: map[DatabaseConstants.columnClientPassportNumber] as String,
      phone: map[DatabaseConstants.columnClientPhone] as String?,
      address: map[DatabaseConstants.columnClientAddress] as String?,
      createdAt: map[DatabaseConstants.columnCreatedAt] as String,
      updatedAt: map[DatabaseConstants.columnUpdatedAt] as String,
    );
  }

  Client copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? username,
    String? password,
    String? role,
    String? authToken,
    String? passportNumber,
    String? phone,
    String? address,
    String? createdAt,
    String? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      authToken: authToken ?? this.authToken,
      passportNumber: passportNumber ?? this.passportNumber,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

