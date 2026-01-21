import '../core/models/client.dart';
import '../core/database/database_helper.dart';
import '../data/repositories/client_repository.dart';
import '../data/repositories/reservation_repository.dart';

class ClientService {
  final ClientRepository _repository = ClientRepository();
  final ReservationRepository _reservationRepository = ReservationRepository();

  Future<int> createClient({
    required String firstName,
    required String lastName,
    required String email,
    required String passportNumber,
    String? phone,
    String? address,
  }) async {
    // Check for duplicate email
    final existingEmail = await _repository.getByEmail(email);
    if (existingEmail != null) {
      throw Exception('A client with this email already exists');
    }

    // Check for duplicate passport
    final existingPassport = await _repository.getByPassportNumber(passportNumber);
    if (existingPassport != null) {
      throw Exception('A client with this passport number already exists');
    }

    final now = DatabaseHelper.getCurrentTimestamp();
    // Generate username from email (before @) and password as default
    final username = email.split('@').first;
    final defaultPassword = 'default123'; // This should be hashed, but for now using simple value
    final client = Client(
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: username,
      password: defaultPassword,
      role: 'user',
      passportNumber: passportNumber,
      phone: phone,
      address: address,
      createdAt: now,
      updatedAt: now,
    );
    return await _repository.create(client);
  }

  Future<List<Client>> getAllClients() async {
    return await _repository.getAll();
  }

  Future<Client?> getClientById(int id) async {
    return await _repository.getById(id);
  }

  Future<bool> updateClient(Client client) async {
    // Check for duplicate email (excluding current client)
    final existingEmail = await _repository.getByEmail(client.email);
    if (existingEmail != null && existingEmail.id != client.id) {
      throw Exception('A client with this email already exists');
    }

    // Check for duplicate passport (excluding current client)
    final existingPassport = await _repository.getByPassportNumber(client.passportNumber);
    if (existingPassport != null && existingPassport.id != client.id) {
      throw Exception('A client with this passport number already exists');
    }

    final updated = client.copyWith(
      updatedAt: DatabaseHelper.getCurrentTimestamp(),
    );
    final result = await _repository.update(updated);
    return result > 0;
  }

  Future<bool> deleteClient(int id) async {
    final result = await _repository.delete(id);
    return result > 0;
  }

  Future<List<Client>> searchClients(String query) async {
    if (query.isEmpty) return await getAllClients();
    return await _repository.search(query);
  }

  Future<double> getClientTotalSpent(int clientId) async {
    final reservations = await _reservationRepository.getByClientId(clientId);
    return reservations.fold<double>(0.0, (sum, reservation) => sum + reservation.totalPrice);
  }

  Future<int> getClientTripCount(int clientId) async {
    final reservations = await _reservationRepository.getByClientId(clientId);
    return reservations.length;
  }

  Future<int> getTotalClientsCount() async {
    return await _repository.getCount();
  }
}

