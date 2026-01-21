import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/database/database_constants.dart';
import '../../core/models/destination.dart';

class DestinationDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(Destination destination) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseConstants.tableDestinations,
      destination.toMap(),
    );
  }

  Future<List<Destination>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableDestinations,
      orderBy: '${DatabaseConstants.columnDestinationName} ASC',
    );
    return List.generate(maps.length, (i) => Destination.fromMap(maps[i]));
  }

  Future<Destination?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableDestinations,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Destination.fromMap(maps.first);
  }

  Future<int> update(Destination destination) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseConstants.tableDestinations,
      destination.toMap(),
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [destination.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseConstants.tableDestinations,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Destination>> search(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableDestinations,
      where: '${DatabaseConstants.columnDestinationName} LIKE ? OR ${DatabaseConstants.columnDestinationCountry} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: '${DatabaseConstants.columnDestinationName} ASC',
    );
    return List.generate(maps.length, (i) => Destination.fromMap(maps[i]));
  }

  Future<List<Destination>> filterByCountry(String country) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableDestinations,
      where: '${DatabaseConstants.columnDestinationCountry} = ?',
      whereArgs: [country],
      orderBy: '${DatabaseConstants.columnDestinationName} ASC',
    );
    return List.generate(maps.length, (i) => Destination.fromMap(maps[i]));
  }

  Future<List<Destination>> filterByPriceRange(double minPrice, double maxPrice) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableDestinations,
      where: '${DatabaseConstants.columnDestinationBasePrice} >= ? AND ${DatabaseConstants.columnDestinationBasePrice} <= ?',
      whereArgs: [minPrice, maxPrice],
      orderBy: '${DatabaseConstants.columnDestinationBasePrice} ASC',
    );
    return List.generate(maps.length, (i) => Destination.fromMap(maps[i]));
  }

  Future<List<String>> getAllCountries() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableDestinations,
      columns: [DatabaseConstants.columnDestinationCountry],
      distinct: true,
    );
    return maps.map((map) => map[DatabaseConstants.columnDestinationCountry] as String).toList();
  }

  Future<double> getAveragePrice() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT AVG(${DatabaseConstants.columnDestinationBasePrice}) as avg_price FROM ${DatabaseConstants.tableDestinations}',
    );
    if (result.isEmpty || result.first['avg_price'] == null) return 0.0;
    return (result.first['avg_price'] as num).toDouble();
  }

  Future<Destination?> getMostExpensive() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableDestinations,
      orderBy: '${DatabaseConstants.columnDestinationBasePrice} DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Destination.fromMap(maps.first);
  }

  Future<Destination?> getCheapest() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableDestinations,
      orderBy: '${DatabaseConstants.columnDestinationBasePrice} ASC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Destination.fromMap(maps.first);
  }
}

