import '../../core/models/additional_service.dart';
import '../daos/additional_service_dao.dart';

class AdditionalServiceRepository {
  final AdditionalServiceDao _dao = AdditionalServiceDao();

  Future<int> create(AdditionalService service) async {
    return await _dao.insert(service);
  }

  Future<List<AdditionalService>> getAll() async {
    return await _dao.getAll();
  }

  Future<AdditionalService?> getById(int id) async {
    return await _dao.getById(id);
  }

  Future<int> update(AdditionalService service) async {
    return await _dao.update(service);
  }

  Future<int> delete(int id) async {
    return await _dao.delete(id);
  }

  Future<List<AdditionalService>> getByCategory(String category) async {
    return await _dao.getByCategory(category);
  }

  Future<List<String>> getAllCategories() async {
    return await _dao.getAllCategories();
  }

  Future<List<AdditionalService>> getByReservationId(int reservationId) async {
    return await _dao.getByReservationId(reservationId);
  }

  Future<double> getTotalRevenue() async {
    return await _dao.getTotalRevenue();
  }

  Future<double> getAveragePrice() async {
    return await _dao.getAveragePrice();
  }

  Future<Map<int, int>> getServiceUsageCount() async {
    return await _dao.getServiceUsageCount();
  }
}

