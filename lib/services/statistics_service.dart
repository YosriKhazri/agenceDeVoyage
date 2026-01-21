import '../data/repositories/destination_repository.dart';
import '../data/repositories/client_repository.dart';
import '../data/repositories/reservation_repository.dart';
import '../data/repositories/review_repository.dart';
import '../data/repositories/additional_service_repository.dart';
import '../core/models/reservation.dart';

class StatisticsService {
  final DestinationRepository _destinationRepository = DestinationRepository();
  final ClientRepository _clientRepository = ClientRepository();
  final ReservationRepository _reservationRepository = ReservationRepository();
  final ReviewRepository _reviewRepository = ReviewRepository();
  final AdditionalServiceRepository _serviceRepository = AdditionalServiceRepository();

  Future<Map<String, dynamic>> getDashboardStatistics() async {
    final destinations = await _destinationRepository.getAll();
    final clients = await _clientRepository.getAll();
    final reservations = await _reservationRepository.getAll();
    final reviews = await _reviewRepository.getAll();
    final totalRevenue = await _reservationRepository.getTotalRevenue();
    final averageRating = await _reviewRepository.getOverallAverageRating();

    final activeReservations = reservations.where(
      (r) => r.status == ReservationStatus.pending || r.status == ReservationStatus.confirmed,
    ).length;

    final pendingReservations = reservations.where(
      (r) => r.status == ReservationStatus.pending,
    ).length;

    return {
      'totalDestinations': destinations.length,
      'totalClients': clients.length,
      'totalReservations': reservations.length,
      'totalReviews': reviews.length,
      'totalRevenue': totalRevenue,
      'activeReservations': activeReservations,
      'pendingReservations': pendingReservations,
      'averageRating': averageRating,
    };
  }

  Future<List<Map<String, dynamic>>> getMonthlyRevenue() async {
    final reservations = await _reservationRepository.getAll();
    final Map<String, double> monthlyRevenue = {};

    for (final reservation in reservations) {
      try {
        final date = DateTime.parse(reservation.departureDate);
        final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0.0) + reservation.totalPrice;
      } catch (e) {
        // Skip invalid dates
      }
    }

    return monthlyRevenue.entries.map((entry) => {
      'month': entry.key,
      'revenue': entry.value,
    }).toList()
      ..sort((a, b) => a['month'].toString().compareTo(b['month'].toString()));
  }

  Future<Map<String, int>> getReservationsByStatus() async {
    final reservations = await _reservationRepository.getAll();
    final Map<String, int> statusCount = {};

    for (final reservation in reservations) {
      final status = reservation.status.name;
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    return statusCount;
  }

  Future<List<Map<String, dynamic>>> getTopDestinations({int limit = 5}) async {
    final destinations = await _destinationRepository.getAll();
    final reservations = await _reservationRepository.getAll();

    final Map<int, int> destinationCount = {};
    for (final reservation in reservations) {
      destinationCount[reservation.destinationId] =
          (destinationCount[reservation.destinationId] ?? 0) + 1;
    }

    final sortedDestinations = destinationCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topDestinations = <Map<String, dynamic>>[];
    for (final entry in sortedDestinations.take(limit)) {
      final destination = destinations.firstWhere((d) => d.id == entry.key);
      topDestinations.add({
        'destination': destination,
        'count': entry.value,
      });
    }

    return topDestinations;
  }
}

