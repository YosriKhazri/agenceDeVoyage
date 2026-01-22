import '../core/models/reservation.dart';
import '../core/database/database_helper.dart';
import '../core/utils/date_formatter.dart';
import '../data/repositories/reservation_repository.dart';
import '../data/repositories/destination_repository.dart';
import '../data/repositories/additional_service_repository.dart';
import '../data/repositories/reservation_service_repository.dart';

class ReservationService {
  final ReservationRepository _repository = ReservationRepository();
  final DestinationRepository _destinationRepository = DestinationRepository();
  final AdditionalServiceRepository _serviceRepository = AdditionalServiceRepository();
  final ReservationServiceRepository _reservationServiceRepository = ReservationServiceRepository();

  Future<int> createReservation({
    required int clientId,
    required int destinationId,
    required String departureDate,
    required String returnDate,
    required int numberOfGuests,
    List<int>? serviceIds,
    String? notes,
  }) async {
    // Validate dates
    final dateError = DateFormatter.parseDate(departureDate);
    final returnDateParsed = DateFormatter.parseDate(returnDate);
    if (dateError == null || returnDateParsed == null) {
      throw Exception('Invalid dates');
    }
    if (returnDateParsed.isBefore(dateError) || returnDateParsed.isAtSameMomentAs(dateError)) {
      throw Exception('Return date must be after departure date');
    }

    // Check for overlapping reservations
    final overlapping = await _repository.checkOverlappingReservations(
      clientId,
      departureDate,
      returnDate,
    );
    if (overlapping.isNotEmpty) {
      throw Exception('Client has overlapping reservations');
    }

    // Get destination to calculate base price
    final destination = await _destinationRepository.getById(destinationId);
    if (destination == null) {
      throw Exception('Destination not found');
    }

    // Calculate total price
    double totalPrice = destination.basePrice * numberOfGuests;
    if (serviceIds != null && serviceIds.isNotEmpty) {
      for (final serviceId in serviceIds) {
        final service = await _serviceRepository.getById(serviceId);
        if (service != null) {
          totalPrice += service.price;
        }
      }
    }

    final now = DatabaseHelper.getCurrentTimestamp();
    final reservation = Reservation(
      clientId: clientId,
      destinationId: destinationId,
      departureDate: departureDate,
      returnDate: returnDate,
      numberOfGuests: numberOfGuests,
      totalPrice: totalPrice,
      status: ReservationStatus.pending,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    final reservationId = await _repository.create(reservation);

    // Add services to reservation
    if (serviceIds != null && serviceIds.isNotEmpty) {
      for (final serviceId in serviceIds) {
        await _reservationServiceRepository.addServiceToReservation(reservationId, serviceId);
      }
    }

    return reservationId;
  }

  Future<List<Reservation>> getAllReservations({int? userId}) async {
    if (userId != null) {
      return await _repository.getByClientId(userId);
    }
    return await _repository.getAll();
  }

  Future<Reservation?> getReservationById(int id) async {
    return await _repository.getById(id);
  }

  Future<bool> updateReservation(Reservation reservation) async {
    final updated = reservation.copyWith(
      updatedAt: DatabaseHelper.getCurrentTimestamp(),
    );
    final result = await _repository.update(updated);
    return result > 0;
  }

  Future<bool> updateReservationServices(int reservationId, List<int> serviceIds) async {
    // Remove all existing services
    await _reservationServiceRepository.removeAllServicesFromReservation(reservationId);

    // Add new services
    for (final serviceId in serviceIds) {
      await _reservationServiceRepository.addServiceToReservation(reservationId, serviceId);
    }

    // Recalculate total price
    final reservation = await _repository.getById(reservationId);
    if (reservation != null) {
      final destination = await _destinationRepository.getById(reservation.destinationId);
      if (destination != null) {
        double totalPrice = destination.basePrice * reservation.numberOfGuests;
        for (final serviceId in serviceIds) {
          final service = await _serviceRepository.getById(serviceId);
          if (service != null) {
            totalPrice += service.price;
          }
        }
        final updated = reservation.copyWith(
          totalPrice: totalPrice,
          updatedAt: DatabaseHelper.getCurrentTimestamp(),
        );
        await _repository.update(updated);
      }
    }

    return true;
  }

  Future<List<int>> getServiceIdsByReservationId(int reservationId) async {
    return await _reservationServiceRepository.getServiceIdsByReservationId(reservationId);
  }

  Future<bool> deleteReservation(int id) async {
    // Remove all services first
    await _reservationServiceRepository.removeAllServicesFromReservation(id);
    final result = await _repository.delete(id);
    return result > 0;
  }

  Future<List<Reservation>> getReservationsByClient(int clientId) async {
    return await _repository.getByClientId(clientId);
  }

  Future<List<Reservation>> getReservationsByDestination(int destinationId) async {
    return await _repository.getByDestinationId(destinationId);
  }

  Future<List<Reservation>> getReservationsByStatus(ReservationStatus status) async {
    return await _repository.getByStatus(status.name);
  }

  Future<List<Reservation>> getUpcomingReservations({int days = 30}) async {
    final fromDate = DateTime.now();
    return await _repository.getUpcoming(fromDate);
  }

  Future<double> calculateTotalPrice({
    required int destinationId,
    required int numberOfGuests,
    List<int>? serviceIds,
  }) async {
    final destination = await _destinationRepository.getById(destinationId);
    if (destination == null) return 0.0;

    double total = destination.basePrice * numberOfGuests;
    if (serviceIds != null && serviceIds.isNotEmpty) {
      for (final serviceId in serviceIds) {
        final service = await _serviceRepository.getById(serviceId);
        if (service != null) {
          total += service.price;
        }
      }
    }
    return total;
  }

  Future<int> calculateNights(String departureDate, String returnDate) async {
    return DateFormatter.calculateDaysBetween(departureDate, returnDate);
  }

  Future<double> getTotalRevenue() async {
    return await _repository.getTotalRevenue();
  }

  Future<int> getReservationsCount() async {
    return await _repository.getCount();
  }
}

