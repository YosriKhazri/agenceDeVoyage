import '../core/models/destination.dart';
import '../core/database/database_helper.dart';
import '../data/repositories/destination_repository.dart';

class DestinationService {
  final DestinationRepository _repository = DestinationRepository();

  Future<int> createDestination({
    required String name,
    required String country,
    String? city,
    String? imageUrl,
    String? description,
    required double basePrice,
  }) async {
    final now = DatabaseHelper.getCurrentTimestamp();
    final destination = Destination(
      name: name,
      country: country,
      city: city,
      imageUrl: imageUrl,
      description: description,
      basePrice: basePrice,
      createdAt: now,
      updatedAt: now,
    );
    return await _repository.create(destination);
  }

  Future<List<Destination>> getAllDestinations() async {
    return await _repository.getAll();
  }

  Future<Destination?> getDestinationById(int id) async {
    return await _repository.getById(id);
  }

  Future<bool> updateDestination(Destination destination) async {
    final updated = destination.copyWith(
      updatedAt: DatabaseHelper.getCurrentTimestamp(),
    );
    final result = await _repository.update(updated);
    return result > 0;
  }

  Future<bool> deleteDestination(int id) async {
    final result = await _repository.delete(id);
    return result > 0;
  }

  Future<List<Destination>> searchDestinations(String query) async {
    if (query.isEmpty) return await getAllDestinations();
    return await _repository.search(query);
  }

  Future<List<Destination>> filterDestinationsByCountry(String country) async {
    return await _repository.filterByCountry(country);
  }

  Future<List<Destination>> filterDestinationsByPriceRange(double minPrice, double maxPrice) async {
    return await _repository.filterByPriceRange(minPrice, maxPrice);
  }

  Future<List<String>> getAllCountries() async {
    return await _repository.getAllCountries();
  }

  Future<double> getAveragePrice() async {
    return await _repository.getAveragePrice();
  }

  Future<Destination?> getMostExpensiveDestination() async {
    return await _repository.getMostExpensive();
  }

  Future<Destination?> getCheapestDestination() async {
    return await _repository.getCheapest();
  }
}

