import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/database/database_constants.dart';
import '../../core/models/reservation.dart';

class ReservationDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(Reservation reservation) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseConstants.tableReservations,
      reservation.toMap(),
    );
  }

  Future<List<Reservation>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReservations,
      orderBy: '${DatabaseConstants.columnReservationDepartureDate} DESC',
    );
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  Future<Reservation?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReservations,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Reservation.fromMap(maps.first);
  }

  Future<int> update(Reservation reservation) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseConstants.tableReservations,
      reservation.toMap(),
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [reservation.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseConstants.tableReservations,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Reservation>> getByClientId(int clientId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReservations,
      where: '${DatabaseConstants.columnReservationClientId} = ?',
      whereArgs: [clientId],
      orderBy: '${DatabaseConstants.columnReservationDepartureDate} DESC',
    );
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  Future<List<Reservation>> getByDestinationId(int destinationId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReservations,
      where: '${DatabaseConstants.columnReservationDestinationId} = ?',
      whereArgs: [destinationId],
      orderBy: '${DatabaseConstants.columnReservationDepartureDate} DESC',
    );
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  Future<List<Reservation>> getByStatus(String status) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReservations,
      where: '${DatabaseConstants.columnReservationStatus} = ?',
      whereArgs: [status],
      orderBy: '${DatabaseConstants.columnReservationDepartureDate} DESC',
    );
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  Future<List<Reservation>> getByDateRange(String startDate, String endDate) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReservations,
      where: '''
        ${DatabaseConstants.columnReservationDepartureDate} >= ? AND 
        ${DatabaseConstants.columnReservationDepartureDate} <= ?
      ''',
      whereArgs: [startDate, endDate],
      orderBy: '${DatabaseConstants.columnReservationDepartureDate} ASC',
    );
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  Future<List<Reservation>> getUpcoming(DateTime fromDate) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReservations,
      where: '${DatabaseConstants.columnReservationDepartureDate} >= ?',
      whereArgs: [fromDate.toIso8601String()],
      orderBy: '${DatabaseConstants.columnReservationDepartureDate} ASC',
    );
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  Future<double> getTotalRevenue() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(${DatabaseConstants.columnReservationTotalPrice}) as total FROM ${DatabaseConstants.tableReservations}',
    );
    if (result.isEmpty || result.first['total'] == null) return 0.0;
    return (result.first['total'] as num).toDouble();
  }

  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableReservations}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Reservation>> checkOverlappingReservations(int clientId, String departureDate, String returnDate) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReservations,
      where: '''
        ${DatabaseConstants.columnReservationClientId} = ? AND
        ${DatabaseConstants.columnReservationStatus} != 'cancelled' AND
        (
          (${DatabaseConstants.columnReservationDepartureDate} <= ? AND ${DatabaseConstants.columnReservationReturnDate} >= ?) OR
          (${DatabaseConstants.columnReservationDepartureDate} <= ? AND ${DatabaseConstants.columnReservationReturnDate} >= ?) OR
          (${DatabaseConstants.columnReservationDepartureDate} >= ? AND ${DatabaseConstants.columnReservationReturnDate} <= ?)
        )
      ''',
      whereArgs: [clientId, departureDate, departureDate, returnDate, returnDate, departureDate, returnDate],
    );
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }
}

