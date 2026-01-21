import 'package:flutter/foundation.dart';
import '../core/models/destination.dart';
import '../services/destination_service.dart';

class DestinationController extends ChangeNotifier {
  final DestinationService _service = DestinationService();

  List<Destination> _destinations = [];
  List<Destination> _filteredDestinations = [];
  bool _isLoading = false;
  String? _error;
  Destination? _selectedDestination;

  List<Destination> get destinations => _filteredDestinations.isEmpty ? _destinations : _filteredDestinations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Destination? get selectedDestination => _selectedDestination;

  Future<void> loadDestinations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _destinations = await _service.getAllDestinations();
      _filteredDestinations = [];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDestination({
    required String name,
    required String country,
    String? city,
    String? imageUrl,
    String? description,
    required double basePrice,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createDestination(
        name: name,
        country: country,
        city: city,
        imageUrl: imageUrl,
        description: description,
        basePrice: basePrice,
      );
      await loadDestinations();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDestination(Destination destination) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.updateDestination(destination);
      if (success) {
        await loadDestinations();
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

  Future<bool> deleteDestination(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.deleteDestination(id);
      if (success) {
        await loadDestinations();
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

  Future<void> searchDestinations(String query) async {
    if (query.isEmpty) {
      _filteredDestinations = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _filteredDestinations = await _service.searchDestinations(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByCountry(String? country) async {
    if (country == null || country.isEmpty) {
      _filteredDestinations = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _filteredDestinations = await _service.filterDestinationsByCountry(country);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByPriceRange(double minPrice, double maxPrice) async {
    _isLoading = true;
    notifyListeners();

    try {
      _filteredDestinations = await _service.filterDestinationsByPriceRange(minPrice, maxPrice);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDestination(Destination? destination) {
    _selectedDestination = destination;
    notifyListeners();
  }

  void clearFilters() {
    _filteredDestinations = [];
    notifyListeners();
  }

  Future<Destination?> getDestinationById(int id) async {
    return await _service.getDestinationById(id);
  }
}

