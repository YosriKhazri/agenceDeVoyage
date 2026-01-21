import '../../core/models/review.dart';
import '../daos/review_dao.dart';

class ReviewRepository {
  final ReviewDao _dao = ReviewDao();

  Future<int> create(Review review) async {
    return await _dao.insert(review);
  }

  Future<List<Review>> getAll() async {
    return await _dao.getAll();
  }

  Future<Review?> getById(int id) async {
    return await _dao.getById(id);
  }

  Future<int> update(Review review) async {
    return await _dao.update(review);
  }

  Future<int> delete(int id) async {
    return await _dao.delete(id);
  }

  Future<List<Review>> getByDestinationId(int destinationId) async {
    return await _dao.getByDestinationId(destinationId);
  }

  Future<List<Review>> getByClientId(int clientId) async {
    return await _dao.getByClientId(clientId);
  }

  Future<Review?> getByDestinationAndClient(int destinationId, int clientId) async {
    return await _dao.getByDestinationAndClient(destinationId, clientId);
  }

  Future<List<Review>> getByRating(int rating) async {
    return await _dao.getByRating(rating);
  }

  Future<double> getAverageRatingByDestination(int destinationId) async {
    return await _dao.getAverageRatingByDestination(destinationId);
  }

  Future<double> getOverallAverageRating() async {
    return await _dao.getOverallAverageRating();
  }

  Future<int> getCountByDestination(int destinationId) async {
    return await _dao.getCountByDestination(destinationId);
  }

  Future<Map<int, int>> getRatingDistributionByDestination(int destinationId) async {
    return await _dao.getRatingDistributionByDestination(destinationId);
  }
}

