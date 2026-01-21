import 'package:flutter/foundation.dart';
import '../services/statistics_service.dart';

class DashboardController extends ChangeNotifier {
  final StatisticsService _service = StatisticsService();

  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _statistics = await _service.getDashboardStatistics();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyRevenue() async {
    try {
      return await _service.getMonthlyRevenue();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, int>> getReservationsByStatus() async {
    try {
      return await _service.getReservationsByStatus();
    } catch (e) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getTopDestinations({int limit = 5}) async {
    try {
      return await _service.getTopDestinations(limit: limit);
    } catch (e) {
      return [];
    }
  }
}

