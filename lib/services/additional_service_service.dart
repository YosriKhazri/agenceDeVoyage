import '../core/models/additional_service.dart';
import '../core/database/database_helper.dart';
import '../data/repositories/additional_service_repository.dart';

class AdditionalServiceService {
  final AdditionalServiceRepository _repository = AdditionalServiceRepository();

  Future<int> createService({
    required String name,
    String? description,
    required double price,
    String? category,
  }) async {
    final now = DatabaseHelper.getCurrentTimestamp();
    final service = AdditionalService(
      name: name,
      description: description,
      price: price,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
    return await _repository.create(service);
  }

  Future<List<AdditionalService>> getAllServices() async {
    return await _repository.getAll();
  }

  Future<AdditionalService?> getServiceById(int id) async {
    return await _repository.getById(id);
  }

  Future<bool> updateService(AdditionalService service) async {
    final updated = service.copyWith(
      updatedAt: DatabaseHelper.getCurrentTimestamp(),
    );
    final result = await _repository.update(updated);
    return result > 0;
  }

  Future<bool> deleteService(int id) async {
    final result = await _repository.delete(id);
    return result > 0;
  }

  Future<List<AdditionalService>> getServicesByCategory(String category) async {
    return await _repository.getByCategory(category);
  }

  Future<List<String>> getAllCategories() async {
    return await _repository.getAllCategories();
  }

  Future<List<AdditionalService>> getServicesByReservationId(int reservationId) async {
    return await _repository.getByReservationId(reservationId);
  }

  Future<double> getTotalRevenue() async {
    return await _repository.getTotalRevenue();
  }

  Future<double> getAveragePrice() async {
    return await _repository.getAveragePrice();
  }

  Future<Map<int, int>> getServiceUsageCount() async {
    return await _repository.getServiceUsageCount();
  }
}

