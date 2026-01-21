import 'package:flutter/foundation.dart';
import '../core/models/review.dart';
import '../services/review_service.dart';

class ReviewController extends ChangeNotifier {
  final ReviewService _service = ReviewService();

  List<Review> _reviews = [];
  List<Review> _filteredReviews = [];
  bool _isLoading = false;
  String? _error;
  Review? _selectedReview;

  List<Review> get reviews => _filteredReviews.isEmpty ? _reviews : _filteredReviews;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Review? get selectedReview => _selectedReview;

  Future<void> loadReviews({int? userId, bool isAdmin = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // All users can see all reviews (for viewing)
      _reviews = await _service.getAllReviews(userId: userId);
      _filteredReviews = [];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> canUserModifyReview(int reviewId, int userId, bool isAdmin) async {
    return await _service.canUserModifyReview(reviewId, userId, isAdmin);
  }

  Future<bool> createReview({
    required int destinationId,
    required int clientId,
    required int rating,
    String? comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createReview(
        destinationId: destinationId,
        clientId: clientId,
        rating: rating,
        comment: comment,
      );
      await loadReviews();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReview(Review review) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.updateReview(review);
      if (success) {
        await loadReviews();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReview(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.deleteReview(id);
      if (success) {
        await loadReviews();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReviewsByDestination(int destinationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _filteredReviews = await _service.getReviewsByDestination(destinationId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByRating(int? rating) async {
    if (rating == null) {
      _filteredReviews = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _filteredReviews = await _service.getReviewsByRating(rating);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectReview(Review? review) {
    _selectedReview = review;
    notifyListeners();
  }

  void clearFilters() {
    _filteredReviews = [];
    notifyListeners();
  }

  Future<double> getAverageRatingByDestination(int destinationId) async {
    return await _service.getAverageRatingByDestination(destinationId);
  }

  Future<Map<int, int>> getRatingDistributionByDestination(int destinationId) async {
    return await _service.getRatingDistributionByDestination(destinationId);
  }
}

