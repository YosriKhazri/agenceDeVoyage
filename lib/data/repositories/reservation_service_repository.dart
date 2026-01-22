import '../daos/reservation_service_dao.dart';

class ReservationServiceRepository {
  final ReservationServiceDao _dao = ReservationServiceDao();

  Future<int> addServiceToReservation(int reservationId, int serviceId) async {
    return await _dao.insert(reservationId, serviceId);
  }

  Future<int> removeServiceFromReservation(int reservationId, int serviceId) async {
    return await _dao.delete(reservationId, serviceId);
  }

  Future<int> removeAllServicesFromReservation(int reservationId) async {
    return await _dao.deleteByReservationId(reservationId);
  }

  Future<List<int>> getServiceIdsByReservationId(int reservationId) async {
    return await _dao.getServiceIdsByReservationId(reservationId);
  }

  Future<List<int>> getReservationIdsByServiceId(int serviceId) async {
    return await _dao.getReservationIdsByServiceId(serviceId);
  }
}

