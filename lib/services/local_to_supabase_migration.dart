import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/project.dart';
import '../models/session.dart' as app;
import '../models/task.dart';
import '../repositories/local_project_repository.dart';
import '../repositories/local_session_repository.dart';
import '../repositories/local_task_repository.dart';
import '../shared/logging/app_logger.dart';

class LocalToSupabaseMigration {
  final SharedPreferences _prefs;
  final SupabaseClient _client;

  LocalToSupabaseMigration({
    required SharedPreferences prefs,
    required SupabaseClient client,
  })  : _prefs = prefs,
        _client = client;

  bool get _hasLocalData =>
      _prefs.containsKey(LocalTaskRepository.storageKey) ||
      _prefs.containsKey(LocalProjectRepository.storageKey) ||
      _prefs.containsKey(LocalSessionRepository.storageKey);

  Future<void> migrateIfNeeded() async {
    if (!_hasLocalData) return;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final projectIdMap = await _migrateProjects(userId);
      await _migrateTasks(userId, projectIdMap);
      await _migrateSessions(userId);
      await _clearLocal();

      AppLogger.info(
        domain: 'migration',
        event: 'local_to_supabase_complete',
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        domain: 'migration',
        event: 'local_to_supabase_failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Map<String, String>> _migrateProjects(String userId) async {
    final projects = _readList(LocalProjectRepository.storageKey)
        .map((j) => Project.fromJson(j))
        .toList();

    final idMap = <String, String>{};
    for (final project in projects) {
      final json = project.toJson()..remove('id');
      json['user_id'] = userId;
      final result = await _client
          .from('projects')
          .insert(json)
          .select('id')
          .single();
      idMap[project.id] = result['id'] as String;
    }
    return idMap;
  }

  Future<void> _migrateTasks(
    String userId,
    Map<String, String> projectIdMap,
  ) async {
    final tasks = _readList(LocalTaskRepository.storageKey)
        .map((j) => Task.fromJson(j))
        .toList();

    for (final task in tasks) {
      final json = task.toJson()..remove('id');
      json['project_id'] =
          task.projectId != null ? projectIdMap[task.projectId] : null;
      json['user_id'] = userId;
      await _client.from('tasks').insert(json);
    }
  }

  Future<void> _migrateSessions(String userId) async {
    final sessions = _readList(LocalSessionRepository.storageKey)
        .map((j) => app.Session.fromJson(j))
        .toList();

    for (final session in sessions) {
      final json = session.toJson()..remove('id');
      json['task_id'] = null;
      json['user_id'] = userId;
      await _client.from('sessions').insert(json);
    }
  }

  List<Map<String, dynamic>> _readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    return (json.decode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  Future<void> _clearLocal() async {
    await _prefs.remove(LocalTaskRepository.storageKey);
    await _prefs.remove(LocalProjectRepository.storageKey);
    await _prefs.remove(LocalSessionRepository.storageKey);
  }
}
