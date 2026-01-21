import '../../core/database/database_helper.dart';
import '../../core/database/database_constants.dart';

class ReservationServiceDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(int reservationId, int serviceId) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseConstants.tableReservationServices,
      {
        DatabaseConstants.columnReservationServiceReservationId: reservationId,
        DatabaseConstants.columnReservationServiceServiceId: serviceId,
      },
    );
  }

  Future<int> delete(int reservationId, int serviceId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseConstants.tableReservationServices,
      where: '''
        ${DatabaseConstants.columnReservationServiceReservationId} = ? AND 
        ${DatabaseConstants.columnReservationServiceServiceId} = ?
      ''',
      whereArgs: [reservationId, serviceId],
    );
  }

  Future<int> deleteByReservationId(int reservationId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseConstants.tableReservationServices,
      where: '${DatabaseConstants.columnReservationServiceReservationId} = ?',
      whereArgs: [reservationId],
    );
  }

  Future<List<int>> getServiceIdsByReservationId(int reservationId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReservationServices,
      columns: [DatabaseConstants.columnReservationServiceServiceId],
      where: '${DatabaseConstants.columnReservationServiceReservationId} = ?',
      whereArgs: [reservationId],
    );
    return maps.map((map) => map[DatabaseConstants.columnReservationServiceServiceId] as int).toList();
  }

  Future<List<int>> getReservationIdsByServiceId(int serviceId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReservationServices,
      columns: [DatabaseConstants.columnReservationServiceReservationId],
      where: '${DatabaseConstants.columnReservationServiceServiceId} = ?',
      whereArgs: [serviceId],
    );
    return maps.map((map) => map[DatabaseConstants.columnReservationServiceReservationId] as int).toList();
  }
}

