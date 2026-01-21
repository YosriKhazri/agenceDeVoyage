import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/database/database_constants.dart';
import '../../core/models/review.dart';

class ReviewDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(Review review) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseConstants.tableReviews,
      review.toMap(),
    );
  }

  Future<List<Review>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReviews,
      orderBy: '${DatabaseConstants.columnCreatedAt} DESC',
    );
    return List.generate(maps.length, (i) => Review.fromMap(maps[i]));
  }

  Future<Review?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReviews,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Review.fromMap(maps.first);
  }

  Future<int> update(Review review) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseConstants.tableReviews,
      review.toMap(),
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [review.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseConstants.tableReviews,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Review>> getByDestinationId(int destinationId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReviews,
      where: '${DatabaseConstants.columnReviewDestinationId} = ?',
      whereArgs: [destinationId],
      orderBy: '${DatabaseConstants.columnCreatedAt} DESC',
    );
    return List.generate(maps.length, (i) => Review.fromMap(maps[i]));
  }

  Future<List<Review>> getByClientId(int clientId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReviews,
      where: '${DatabaseConstants.columnReviewClientId} = ?',
      whereArgs: [clientId],
      orderBy: '${DatabaseConstants.columnCreatedAt} DESC',
    );
    return List.generate(maps.length, (i) => Review.fromMap(maps[i]));
  }

  Future<Review?> getByDestinationAndClient(int destinationId, int clientId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReviews,
      where: '${DatabaseConstants.columnReviewDestinationId} = ? AND ${DatabaseConstants.columnReviewClientId} = ?',
      whereArgs: [destinationId, clientId],
    );
    if (maps.isEmpty) return null;
    return Review.fromMap(maps.first);
  }

  Future<List<Review>> getByRating(int rating) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReviews,
      where: '${DatabaseConstants.columnReviewRating} = ?',
      whereArgs: [rating],
      orderBy: '${DatabaseConstants.columnCreatedAt} DESC',
    );
    return List.generate(maps.length, (i) => Review.fromMap(maps[i]));
  }

  Future<double> getAverageRatingByDestination(int destinationId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT AVG(${DatabaseConstants.columnReviewRating}) as avg_rating FROM ${DatabaseConstants.tableReviews} WHERE ${DatabaseConstants.columnReviewDestinationId} = ?',
      [destinationId],
    );
    if (result.isEmpty || result.first['avg_rating'] == null) return 0.0;
    return (result.first['avg_rating'] as num).toDouble();
  }

  Future<double> getOverallAverageRating() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT AVG(${DatabaseConstants.columnReviewRating}) as avg_rating FROM ${DatabaseConstants.tableReviews}',
    );
    if (result.isEmpty || result.first['avg_rating'] == null) return 0.0;
    return (result.first['avg_rating'] as num).toDouble();
  }

  Future<int> getCountByDestination(int destinationId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableReviews} WHERE ${DatabaseConstants.columnReviewDestinationId} = ?',
      [destinationId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<int, int>> getRatingDistributionByDestination(int destinationId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT ${DatabaseConstants.columnReviewRating}, COUNT(*) as count FROM ${DatabaseConstants.tableReviews} WHERE ${DatabaseConstants.columnReviewDestinationId} = ? GROUP BY ${DatabaseConstants.columnReviewRating}',
      [destinationId],
    );
    final distribution = <int, int>{};
    for (var row in result) {
      distribution[row[DatabaseConstants.columnReviewRating] as int] = row['count'] as int;
    }
    return distribution;
  }
}

