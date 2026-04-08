import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'project_repository.dart';

class LocalProjectRepository implements ProjectRepository {
  static const storageKey = 'local_projects';

  final SharedPreferences _prefs;
  int _nextId = 0;

  LocalProjectRepository(this._prefs);

  @override
  Future<List<Project>> getAll() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return [];
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((j) => Project.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> add(Project project) async {
    final projects = await getAll();
    final id = project.id.isEmpty ? 'local_proj_${_nextId++}' : project.id;
    projects.add(
      Project(id: id, name: project.name, style: project.style),
    );
    await _save(projects);
  }

  Future<void> _save(List<Project> projects) async {
    final encoded = json.encode(projects.map((p) => p.toJson()).toList());
    await _prefs.setString(storageKey, encoded);
  }
}
