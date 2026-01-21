import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/database/database_constants.dart';
import '../../core/models/client.dart';

class ClientDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(Client client) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseConstants.tableClients,
      client.toMap(),
    );
  }

  Future<List<Client>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableClients,
      orderBy: '${DatabaseConstants.columnClientLastName} ASC, ${DatabaseConstants.columnClientFirstName} ASC',
    );
    return List.generate(maps.length, (i) => Client.fromMap(maps[i]));
  }

  Future<Client?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableClients,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Client.fromMap(maps.first);
  }

  Future<int> update(Client client) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseConstants.tableClients,
      client.toMap(),
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseConstants.tableClients,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Client>> search(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableClients,
      where: '''
        ${DatabaseConstants.columnClientFirstName} LIKE ? OR 
        ${DatabaseConstants.columnClientLastName} LIKE ? OR 
        ${DatabaseConstants.columnClientEmail} LIKE ? OR 
        ${DatabaseConstants.columnClientPassportNumber} LIKE ? OR 
        ${DatabaseConstants.columnClientPhone} LIKE ?
      ''',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: '${DatabaseConstants.columnClientLastName} ASC',
    );
    return List.generate(maps.length, (i) => Client.fromMap(maps[i]));
  }

  Future<Client?> getByEmail(String email) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableClients,
      where: '${DatabaseConstants.columnClientEmail} = ?',
      whereArgs: [email],
    );
    if (maps.isEmpty) return null;
    return Client.fromMap(maps.first);
  }

  Future<Client?> getByPassportNumber(String passportNumber) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableClients,
      where: '${DatabaseConstants.columnClientPassportNumber} = ?',
      whereArgs: [passportNumber],
    );
    if (maps.isEmpty) return null;
    return Client.fromMap(maps.first);
  }

  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableClients}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Client?> getByUsername(String username) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableClients,
      where: '${DatabaseConstants.columnClientUsername} = ?',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return Client.fromMap(maps.first);
  }

  Future<Client?> getByToken(String token) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableClients,
      where: '${DatabaseConstants.columnClientAuthToken} = ?',
      whereArgs: [token],
    );
    if (maps.isEmpty) return null;
    return Client.fromMap(maps.first);
  }

  Future<int> updateToken(int userId, String? token) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseConstants.tableClients,
      {DatabaseConstants.columnClientAuthToken: token},
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [userId],
    );
  }
}

