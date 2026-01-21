import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'database_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DatabaseConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: DatabaseConstants.databaseVersion,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(DatabaseConstants.createTableDestinations);
    await db.execute(DatabaseConstants.createTableClients);
    await db.execute(DatabaseConstants.createTableReservations);
    await db.execute(DatabaseConstants.createTableReviews);
    await db.execute(DatabaseConstants.createTableAdditionalServices);
    await db.execute(DatabaseConstants.createTableReservationServices);
    
    // Create default admin account
    await _createDefaultAdmin(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2 && newVersion >= 2) {
      // Add city column to destinations table if it doesn't exist
      await db.execute(
        'ALTER TABLE ${DatabaseConstants.tableDestinations} '
        'ADD COLUMN ${DatabaseConstants.columnDestinationCity} TEXT',
      );
    }
    
    if (oldVersion < 3 && newVersion >= 3) {
      // Add authentication columns to clients table
      try {
        await db.execute(
          'ALTER TABLE ${DatabaseConstants.tableClients} '
          'ADD COLUMN ${DatabaseConstants.columnClientUsername} TEXT',
        );
      } catch (e) {
        // Column might already exist
      }
      
      try {
        await db.execute(
          'ALTER TABLE ${DatabaseConstants.tableClients} '
          'ADD COLUMN ${DatabaseConstants.columnClientPassword} TEXT',
        );
      } catch (e) {
        // Column might already exist
      }
      
      try {
        await db.execute(
          'ALTER TABLE ${DatabaseConstants.tableClients} '
          'ADD COLUMN ${DatabaseConstants.columnClientRole} TEXT DEFAULT \'user\'',
        );
      } catch (e) {
        // Column might already exist
      }
      
      try {
        await db.execute(
          'ALTER TABLE ${DatabaseConstants.tableClients} '
          'ADD COLUMN ${DatabaseConstants.columnClientAuthToken} TEXT',
        );
      } catch (e) {
        // Column might already exist
      }
      
      // Set default values for existing clients
      await db.execute(
        'UPDATE ${DatabaseConstants.tableClients} '
        'SET ${DatabaseConstants.columnClientUsername} = ${DatabaseConstants.columnClientEmail} '
        'WHERE ${DatabaseConstants.columnClientUsername} IS NULL',
      );
      
      await db.execute(
        'UPDATE ${DatabaseConstants.tableClients} '
        'SET ${DatabaseConstants.columnClientPassword} = \'${_hashPassword('default123')}\' '
        'WHERE ${DatabaseConstants.columnClientPassword} IS NULL',
      );
      
      await db.execute(
        'UPDATE ${DatabaseConstants.tableClients} '
        'SET ${DatabaseConstants.columnClientRole} = \'user\' '
        'WHERE ${DatabaseConstants.columnClientRole} IS NULL',
      );
      
      // Create default admin account if it doesn't exist
      await _createDefaultAdmin(db);
    }
  }
  
  Future<void> _createDefaultAdmin(Database db) async {
    try {
      // Check if admin already exists
      final adminCheck = await db.query(
        DatabaseConstants.tableClients,
        where: '${DatabaseConstants.columnClientEmail} = ?',
        whereArgs: ['admin@travel.com'],
      );
      
      if (adminCheck.isEmpty) {
        // Create default admin account
        final now = getCurrentTimestamp();
        final adminPassword = _hashPassword('admin123');
        
        await db.insert(
          DatabaseConstants.tableClients,
          {
            DatabaseConstants.columnClientFirstName: 'Admin',
            DatabaseConstants.columnClientLastName: 'User',
            DatabaseConstants.columnClientEmail: 'admin@travel.com',
            DatabaseConstants.columnClientUsername: 'admin',
            DatabaseConstants.columnClientPassword: adminPassword,
            DatabaseConstants.columnClientRole: 'admin',
            DatabaseConstants.columnClientPassportNumber: 'ADMIN001',
            DatabaseConstants.columnCreatedAt: now,
            DatabaseConstants.columnUpdatedAt: now,
          },
        );
      }
    } catch (e) {
      // Admin might already exist or table structure issue
      debugPrint('Error creating default admin: $e');
    }
  }
  
  String _hashPassword(String password) {
    // Simple hash using base64 encoding (can be upgraded to bcrypt later)
    final bytes = utf8.encode(password);
    return base64Encode(bytes);
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }

  // Helper method to get current timestamp
  static String getCurrentTimestamp() {
    return DateTime.now().toIso8601String();
  }
}

