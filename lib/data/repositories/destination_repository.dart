import '../../core/models/destination.dart';
import '../daos/destination_dao.dart';

class DestinationRepository {
  final DestinationDao _dao = DestinationDao();

  Future<int> create(Destination destination) async {
    return await _dao.insert(destination);
  }

  Future<List<Destination>> getAll() async {
    return await _dao.getAll();
  }

  Future<Destination?> getById(int id) async {
    return await _dao.getById(id);
  }

  Future<int> update(Destination destination) async {
    return await _dao.update(destination);
  }

  Future<int> delete(int id) async {
    return await _dao.delete(id);
  }

  Future<List<Destination>> search(String query) async {
    return await _dao.search(query);
  }

  Future<List<Destination>> filterByCountry(String country) async {
    return await _dao.filterByCountry(country);
  }

  Future<List<Destination>> filterByPriceRange(double minPrice, double maxPrice) async {
    return await _dao.filterByPriceRange(minPrice, maxPrice);
  }

  Future<List<String>> getAllCountries() async {
    return await _dao.getAllCountries();
  }

  Future<double> getAveragePrice() async {
    return await _dao.getAveragePrice();
  }

  Future<Destination?> getMostExpensive() async {
    return await _dao.getMostExpensive();
  }

  Future<Destination?> getCheapest() async {
    return await _dao.getCheapest();
  }
}

