import '../../core/models/client.dart';
import '../daos/client_dao.dart';

class AuthRepository {
  final ClientDao _dao = ClientDao();

  Future<Client?> getByEmail(String email) async {
    return await _dao.getByEmail(email);
  }

  Future<Client?> getByUsername(String username) async {
    return await _dao.getByUsername(username);
  }

  Future<Client?> getByEmailOrUsername(String identifier) async {
    // Try email first
    final byEmail = await getByEmail(identifier);
    if (byEmail != null) return byEmail;
    
    // Try username
    return await getByUsername(identifier);
  }

  Future<Client?> getByToken(String token) async {
    return await _dao.getByToken(token);
  }

  Future<int> updateToken(int userId, String? token) async {
    return await _dao.updateToken(userId, token);
  }

  Future<int> create(Client client) async {
    return await _dao.insert(client);
  }

  Future<int> update(Client client) async {
    return await _dao.update(client);
  }
}

