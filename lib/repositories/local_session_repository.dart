import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'session_repository.dart';

class LocalSessionRepository implements SessionRepository {
  static const storageKey = 'local_sessions';

  final SharedPreferences _prefs;

  LocalSessionRepository(this._prefs);

  @override
  Future<List<Session>> getAll() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return [];
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((j) => Session.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> add(Session session) async {
    final sessions = await getAll();
    sessions.insert(0, session);
    await _save(sessions);
  }

  Future<void> _save(List<Session> sessions) async {
    final encoded = json.encode(sessions.map((s) => s.toJson()).toList());
    await _prefs.setString(storageKey, encoded);
  }
}
