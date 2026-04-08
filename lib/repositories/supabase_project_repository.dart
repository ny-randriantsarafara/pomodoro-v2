import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'project_repository.dart';

class SupabaseProjectRepository implements ProjectRepository {
  final SupabaseClient _client;

  SupabaseProjectRepository(this._client);

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<Project>> getAll() async {
    final data = await _client
        .from('projects')
        .select()
        .eq('user_id', _userId)
        .order('created_at');
    return data.map((json) => Project.fromJson(json)).toList();
  }

  @override
  Future<void> add(Project project) async {
    final json = project.toJson()..remove('id');
    await _client.from('projects').insert({
      ...json,
      'user_id': _userId,
    });
  }
}
