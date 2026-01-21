import '../../core/models/reservation.dart';
import '../daos/reservation_dao.dart';

class ReservationRepository {
  final ReservationDao _dao = ReservationDao();

  Future<int> create(Reservation reservation) async {
    return await _dao.insert(reservation);
  }

  Future<List<Reservation>> getAll() async {
    return await _dao.getAll();
  }

  Future<Reservation?> getById(int id) async {
    return await _dao.getById(id);
  }

  Future<int> update(Reservation reservation) async {
    return await _dao.update(reservation);
  }

  Future<int> delete(int id) async {
    return await _dao.delete(id);
  }

  Future<List<Reservation>> getByClientId(int clientId) async {
    return await _dao.getByClientId(clientId);
  }

  Future<List<Reservation>> getByDestinationId(int destinationId) async {
    return await _dao.getByDestinationId(destinationId);
  }

  Future<List<Reservation>> getByStatus(String status) async {
    return await _dao.getByStatus(status);
  }

  Future<List<Reservation>> getByDateRange(String startDate, String endDate) async {
    return await _dao.getByDateRange(startDate, endDate);
  }

  Future<List<Reservation>> getUpcoming(DateTime fromDate) async {
    return await _dao.getUpcoming(fromDate);
  }

  Future<double> getTotalRevenue() async {
    return await _dao.getTotalRevenue();
  }

  Future<int> getCount() async {
    return await _dao.getCount();
  }

  Future<List<Reservation>> checkOverlappingReservations(
    int clientId,
    String departureDate,
    String returnDate,
  ) async {
    return await _dao.checkOverlappingReservations(clientId, departureDate, returnDate);
  }
}

