import '../models/models.dart';

abstract class SessionRepository {
  List<Session> getAll();
  void add(Session session);
}

class InMemorySessionRepository implements SessionRepository {
  final List<Session> _sessions;

  InMemorySessionRepository({List<Session>? initial})
      : _sessions = initial ?? [];

  @override
  List<Session> getAll() => List.unmodifiable(_sessions);

  @override
  void add(Session session) => _sessions.insert(0, session);
}
