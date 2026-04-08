import '../models/models.dart';

abstract class SessionRepository {
  Future<List<Session>> getAll();
  Future<void> add(Session session);
}
