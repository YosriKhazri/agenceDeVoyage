import '../core/models/review.dart';
import '../core/database/database_helper.dart';
import '../data/repositories/review_repository.dart';
import '../data/repositories/reservation_repository.dart';

class ReviewService {
  final ReviewRepository _repository = ReviewRepository();
  final ReservationRepository _reservationRepository = ReservationRepository();

  Future<int> createReview({
    required int destinationId,
    required int clientId,
    required int rating,
    String? comment,
  }) async {
    // Validate rating
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }

    // Check if client has booked this destination
    final reservations = await _reservationRepository.getByClientId(clientId);
    final hasBooked = reservations.any((r) => r.destinationId == destinationId);
    if (!hasBooked) {
      throw Exception('Client must have booked this destination to leave a review');
    }

    // Check for duplicate review
    final existingReview = await _repository.getByDestinationAndClient(destinationId, clientId);
    if (existingReview != null) {
      throw Exception('Client has already reviewed this destination');
    }

    final now = DatabaseHelper.getCurrentTimestamp();
    final review = Review(
      destinationId: destinationId,
      clientId: clientId,
      rating: rating,
      comment: comment,
      createdAt: now,
      updatedAt: now,
    );
    return await _repository.create(review);
  }

  Future<List<Review>> getAllReviews({int? userId}) async {
    // All users can see all reviews, but we track userId for ownership checks
    return await _repository.getAll();
  }

  Future<bool> canUserModifyReview(int reviewId, int userId, bool isAdmin) async {
    if (isAdmin) return true;
    final review = await _repository.getById(reviewId);
    return review != null && review.clientId == userId;
  }

  Future<Review?> getReviewById(int id) async {
    return await _repository.getById(id);
  }

  Future<bool> updateReview(Review review) async {
    // Validate rating
    if (review.rating < 1 || review.rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }

    final updated = review.copyWith(
      updatedAt: DatabaseHelper.getCurrentTimestamp(),
    );
    final result = await _repository.update(updated);
    return result > 0;
  }

  Future<bool> deleteReview(int id) async {
    final result = await _repository.delete(id);
    return result > 0;
  }

  Future<List<Review>> getReviewsByDestination(int destinationId) async {
    return await _repository.getByDestinationId(destinationId);
  }

  Future<List<Review>> getReviewsByClient(int clientId) async {
    return await _repository.getByClientId(clientId);
  }

  Future<List<Review>> getReviewsByRating(int rating) async {
    return await _repository.getByRating(rating);
  }

  Future<double> getAverageRatingByDestination(int destinationId) async {
    return await _repository.getAverageRatingByDestination(destinationId);
  }

  Future<double> getOverallAverageRating() async {
    return await _repository.getOverallAverageRating();
  }

  Future<int> getReviewCountByDestination(int destinationId) async {
    return await _repository.getCountByDestination(destinationId);
  }

  Future<Map<int, int>> getRatingDistributionByDestination(int destinationId) async {
    return await _repository.getRatingDistributionByDestination(destinationId);
  }
}

