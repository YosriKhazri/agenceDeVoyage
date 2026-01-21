import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/database/database_constants.dart';
import '../../core/models/additional_service.dart';

class AdditionalServiceDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(AdditionalService service) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseConstants.tableAdditionalServices,
      service.toMap(),
    );
  }

  Future<List<AdditionalService>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableAdditionalServices,
      orderBy: '${DatabaseConstants.columnServiceName} ASC',
    );
    return List.generate(maps.length, (i) => AdditionalService.fromMap(maps[i]));
  }

  Future<AdditionalService?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableAdditionalServices,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return AdditionalService.fromMap(maps.first);
  }

  Future<int> update(AdditionalService service) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseConstants.tableAdditionalServices,
      service.toMap(),
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [service.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseConstants.tableAdditionalServices,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<AdditionalService>> getByCategory(String category) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableAdditionalServices,
      where: '${DatabaseConstants.columnServiceCategory} = ?',
      whereArgs: [category],
      orderBy: '${DatabaseConstants.columnServiceName} ASC',
    );
    return List.generate(maps.length, (i) => AdditionalService.fromMap(maps[i]));
  }

  Future<List<String>> getAllCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableAdditionalServices,
      columns: [DatabaseConstants.columnServiceCategory],
      distinct: true,
      where: '${DatabaseConstants.columnServiceCategory} IS NOT NULL',
    );
    return maps
        .map((map) => map[DatabaseConstants.columnServiceCategory] as String?)
        .where((category) => category != null)
        .cast<String>()
        .toList();
  }

  Future<List<AdditionalService>> getByReservationId(int reservationId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT s.* FROM ${DatabaseConstants.tableAdditionalServices} s
      INNER JOIN ${DatabaseConstants.tableReservationServices} rs ON s.${DatabaseConstants.columnId} = rs.${DatabaseConstants.columnReservationServiceServiceId}
      WHERE rs.${DatabaseConstants.columnReservationServiceReservationId} = ?
    ''', [reservationId]);
    return List.generate(maps.length, (i) => AdditionalService.fromMap(maps[i]));
  }

  Future<double> getTotalRevenue() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(s.${DatabaseConstants.columnServicePrice}) as total 
      FROM ${DatabaseConstants.tableAdditionalServices} s
      INNER JOIN ${DatabaseConstants.tableReservationServices} rs ON s.${DatabaseConstants.columnId} = rs.${DatabaseConstants.columnReservationServiceServiceId}
    ''');
    if (result.isEmpty || result.first['total'] == null) return 0.0;
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getAveragePrice() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT AVG(${DatabaseConstants.columnServicePrice}) as avg_price FROM ${DatabaseConstants.tableAdditionalServices}',
    );
    if (result.isEmpty || result.first['avg_price'] == null) return 0.0;
    return (result.first['avg_price'] as num).toDouble();
  }

  Future<Map<int, int>> getServiceUsageCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT s.${DatabaseConstants.columnId}, COUNT(rs.${DatabaseConstants.columnReservationServiceReservationId}) as usage_count
      FROM ${DatabaseConstants.tableAdditionalServices} s
      LEFT JOIN ${DatabaseConstants.tableReservationServices} rs ON s.${DatabaseConstants.columnId} = rs.${DatabaseConstants.columnReservationServiceServiceId}
      GROUP BY s.${DatabaseConstants.columnId}
    ''');
    final usageMap = <int, int>{};
    for (var row in result) {
      usageMap[row[DatabaseConstants.columnId] as int] = row['usage_count'] as int;
    }
    return usageMap;
  }
}

