import 'package:flutter/foundation.dart';
import '../core/models/additional_service.dart';
import '../services/additional_service_service.dart';

class AdditionalServiceController extends ChangeNotifier {
  final AdditionalServiceService _service = AdditionalServiceService();

  List<AdditionalService> _services = [];
  List<AdditionalService> _filteredServices = [];
  bool _isLoading = false;
  String? _error;
  AdditionalService? _selectedService;

  List<AdditionalService> get services => _filteredServices.isEmpty ? _services : _filteredServices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AdditionalService? get selectedService => _selectedService;

  Future<void> loadServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _services = await _service.getAllServices();
      _filteredServices = [];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createService({
    required String name,
    String? description,
    required double price,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createService(
        name: name,
        description: description,
        price: price,
        category: category,
      );
      await loadServices();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateService(AdditionalService service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.updateService(service);
      if (success) {
        await loadServices();
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

  Future<bool> deleteService(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.deleteService(id);
      if (success) {
        await loadServices();
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

  Future<void> filterByCategory(String? category) async {
    if (category == null || category.isEmpty) {
      _filteredServices = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _filteredServices = await _service.getServicesByCategory(category);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectService(AdditionalService? service) {
    _selectedService = service;
    notifyListeners();
  }

  void clearFilters() {
    _filteredServices = [];
    notifyListeners();
  }
}

