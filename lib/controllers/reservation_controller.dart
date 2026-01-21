import 'package:flutter/foundation.dart';
import '../core/models/reservation.dart';
import '../services/reservation_service.dart';

class ReservationController extends ChangeNotifier {
  final ReservationService _service = ReservationService();

  List<Reservation> _reservations = [];
  List<Reservation> _filteredReservations = [];
  bool _isLoading = false;
  String? _error;
  Reservation? _selectedReservation;
  int? _lastUserId;
  bool _lastIsAdmin = false;

  List<Reservation> get reservations => _filteredReservations.isEmpty ? _reservations : _filteredReservations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Reservation? get selectedReservation => _selectedReservation;

  Future<void> loadReservations({int? userId, bool isAdmin = false}) async {
    // Store filter parameters for later use
    _lastUserId = userId;
    _lastIsAdmin = isAdmin;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Admin sees all, User sees only their own
      _reservations = await _service.getAllReservations(userId: isAdmin ? null : userId);
      _filteredReservations = [];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _reloadWithLastFilters() async {
    await loadReservations(userId: _lastUserId, isAdmin: _lastIsAdmin);
  }

  Future<bool> createReservation({
    required int clientId,
    required int destinationId,
    required String departureDate,
    required String returnDate,
    required int numberOfGuests,
    List<int>? serviceIds,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createReservation(
        clientId: clientId,
        destinationId: destinationId,
        departureDate: departureDate,
        returnDate: returnDate,
        numberOfGuests: numberOfGuests,
        serviceIds: serviceIds,
        notes: notes,
      );
      await _reloadWithLastFilters();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReservation(Reservation reservation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.updateReservation(reservation);
      if (success) {
        await _reloadWithLastFilters();
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

  Future<bool> approveReservation(Reservation reservation) async {
    final updated = reservation.copyWith(status: ReservationStatus.confirmed);
    return await updateReservation(updated);
  }

  Future<bool> updateReservationServices(int reservationId, List<int> serviceIds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.updateReservationServices(reservationId, serviceIds);
      if (success) {
        await _reloadWithLastFilters();
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

  Future<List<int>> getServiceIdsByReservationId(int reservationId) async {
    return await _service.getServiceIdsByReservationId(reservationId);
  }

  Future<bool> deleteReservation(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.deleteReservation(id);
      if (success) {
        await _reloadWithLastFilters();
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

  Future<void> filterByStatus(ReservationStatus? status) async {
    if (status == null) {
      _filteredReservations = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _filteredReservations = await _service.getReservationsByStatus(status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUpcomingReservations({int days = 30}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _filteredReservations = await _service.getUpcomingReservations(days: days);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectReservation(Reservation? reservation) {
    _selectedReservation = reservation;
    notifyListeners();
  }

  void clearFilters() {
    _filteredReservations = [];
    notifyListeners();
  }

  Future<double> calculateTotalPrice({
    required int destinationId,
    required int numberOfGuests,
    List<int>? serviceIds,
  }) async {
    return await _service.calculateTotalPrice(
      destinationId: destinationId,
      numberOfGuests: numberOfGuests,
      serviceIds: serviceIds,
    );
  }

  Future<int> calculateNights(String departureDate, String returnDate) async {
    return await _service.calculateNights(departureDate, returnDate);
  }
}

