import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'task_repository.dart';

class SupabaseTaskRepository implements TaskRepository {
  final SupabaseClient _client;

  SupabaseTaskRepository(this._client);

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<Task>> getAll() async {
    final data = await _client
        .from('tasks')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
    return data.map((json) => Task.fromJson(json)).toList();
  }

  @override
  Future<void> add(Task task) async {
    final json = task.toJson()..remove('id');
    await _client.from('tasks').insert({
      ...json,
      'user_id': _userId,
    });
  }

  @override
  Future<void> update(Task task) async {
    await _client
        .from('tasks')
        .update({
          'title': task.title,
          'project_id': task.projectId,
          'completed': task.completed,
        })
        .eq('id', task.id)
        .eq('user_id', _userId);
  }

  @override
  Future<void> delete(String id) async {
    await _client
        .from('tasks')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }
}
