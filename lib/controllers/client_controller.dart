import 'package:flutter/foundation.dart';
import '../core/models/client.dart';
import '../services/client_service.dart';

class ClientController extends ChangeNotifier {
  final ClientService _service = ClientService();

  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  bool _isLoading = false;
  String? _error;
  Client? _selectedClient;

  List<Client> get clients => _filteredClients.isEmpty ? _clients : _filteredClients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Client? get selectedClient => _selectedClient;

  Future<void> loadClients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clients = await _service.getAllClients();
      _filteredClients = [];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClient({
    required String firstName,
    required String lastName,
    required String email,
    required String passportNumber,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        passportNumber: passportNumber,
        phone: phone,
        address: address,
      );
      await loadClients();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateClient(Client client) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.updateClient(client);
      if (success) {
        await loadClients();
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

  Future<bool> deleteClient(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.deleteClient(id);
      if (success) {
        await loadClients();
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

  Future<void> searchClients(String query) async {
    if (query.isEmpty) {
      _filteredClients = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _filteredClients = await _service.searchClients(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectClient(Client? client) {
    _selectedClient = client;
    notifyListeners();
  }

  void clearFilters() {
    _filteredClients = [];
    notifyListeners();
  }

  Future<double> getClientTotalSpent(int clientId) async {
    return await _service.getClientTotalSpent(clientId);
  }

  Future<int> getClientTripCount(int clientId) async {
    return await _service.getClientTripCount(clientId);
  }

  Future<Client?> getClientById(int id) async {
    return await _service.getClientById(id);
  }
}

