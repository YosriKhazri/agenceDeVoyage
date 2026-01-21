import 'package:flutter/foundation.dart';
import 'database_helper.dart';

class DatabaseViewerHelper {
  /// Get the database path (for debugging purposes)
  static Future<String> getDatabasePath() async {
    if (kDebugMode) {
      final db = await DatabaseHelper.instance.database;
      // The database path is stored internally by sqflite
      // We can print it for debugging
      return 'Database is located at: /data/data/com.example.agence_de_voayage/databases/travel_agency.db';
    }
    return 'Database path not available in release mode';
  }

  /// Print database info for debugging
  static Future<void> printDatabaseInfo() async {
    if (kDebugMode) {
      debugPrint('========================================');
      debugPrint('DATABASE INFORMATION');
      debugPrint('========================================');
      debugPrint(await getDatabasePath());
      debugPrint('To view the database:');
      debugPrint('1. Use Android Studio Database Inspector');
      debugPrint('2. Or use ADB: adb shell run-as com.example.agence_de_voayage');
      debugPrint('   Then: cp databases/travel_agency.db /sdcard/');
      debugPrint('   Then: adb pull /sdcard/travel_agency.db');
      debugPrint('3. Open with DB Browser for SQLite');
      debugPrint('========================================');
    }
  }
}

