import '../../core/models/client.dart';
import '../daos/client_dao.dart';

class ClientRepository {
  final ClientDao _dao = ClientDao();

  Future<int> create(Client client) async {
    return await _dao.insert(client);
  }

  Future<List<Client>> getAll() async {
    return await _dao.getAll();
  }

  Future<Client?> getById(int id) async {
    return await _dao.getById(id);
  }

  Future<int> update(Client client) async {
    return await _dao.update(client);
  }

  Future<int> delete(int id) async {
    return await _dao.delete(id);
  }

  Future<List<Client>> search(String query) async {
    return await _dao.search(query);
  }

  Future<Client?> getByEmail(String email) async {
    return await _dao.getByEmail(email);
  }

  Future<Client?> getByPassportNumber(String passportNumber) async {
    return await _dao.getByPassportNumber(passportNumber);
  }

  Future<int> getCount() async {
    return await _dao.getCount();
  }
}

