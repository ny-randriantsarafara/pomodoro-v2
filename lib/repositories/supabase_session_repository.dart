import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import '../models/models.dart';
import 'session_repository.dart';

class SupabaseSessionRepository implements SessionRepository {
  final SupabaseClient _client;

  SupabaseSessionRepository(this._client);

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<Session>> getAll() async {
    final data = await _client
        .from('sessions')
        .select()
        .eq('user_id', _userId)
        .order('completed_at', ascending: false);
    return data.map((json) => Session.fromJson(json)).toList();
  }

  @override
  Future<void> add(Session session) async {
    final json = session.toJson()..remove('id');
    await _client.from('sessions').insert({
      ...json,
      'user_id': _userId,
    });
  }
}
