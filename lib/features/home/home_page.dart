import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../shared/widgets/anchored_overlay.dart';
import '../../shared/widgets/page_entry_animation.dart';
import '../../shared/widgets/preset_picker.dart';
import '../../shared/utils/format_helpers.dart';
import '../../store/providers.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'widgets/today_header.dart';
import 'widgets/next_focus_hero.dart';
import 'widgets/task_composer.dart';
import 'widgets/post_create_affordance.dart';
import 'widgets/project_dropdown.dart';
import 'widgets/task_row.dart';
import 'widgets/task_overflow_menu.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/empty_task_state.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _newTaskController = TextEditingController();
  final _composerFocusNode = FocusNode();
  String? _selectedProjectId;
  // ignore: unused_field
  bool _isProjectDropdownOpen = false;
  bool _isAddingProject = false;
  String _newProjectName = '';
  // ignore: unused_field
  String? _activePresetTaskId;
  // ignore: unused_field
  String? _activeMenuTaskId;
  String _searchQuery = '';
  String _filterProjectId = 'all';
  ({String id, String title})? _postCreate;
  Timer? _postCreateTimer;

  final _composerProjectLink = LayerLink();
  final Map<String, LayerLink> _presetLinks = {};
  final Map<String, LayerLink> _menuLinks = {};
  OverlayEntry? _currentOverlay;

  @override
  void initState() {
    super.initState();
    _newTaskController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    _composerFocusNode.dispose();
    _postCreateTimer?.cancel();
    _closeAllOverlays();
    super.dispose();
  }

  void _closeAllOverlays() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    _isProjectDropdownOpen = false;
    _activePresetTaskId = null;
    _activeMenuTaskId = null;
  }

  void _showOverlay(OverlayEntry entry) {
    _closeAllOverlays();
    _currentOverlay = entry;
    Overlay.of(context).insert(entry);
  }

  void _addTask() {
    final title = _newTaskController.text.trim();
    if (title.isEmpty) return;
    final store = ref.read(appStoreProvider);
    store.addTask(title, projectId: _selectedProjectId);
    final newTask = store.tasks.first;
    _newTaskController.clear();
    _selectedProjectId = null;
    _closeAllOverlays();
    setState(() {
      _postCreate = (id: newTask.id, title: newTask.title);
    });
    _postCreateTimer?.cancel();
    _postCreateTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _postCreate = null);
    });
  }

  void _openProjectDropdown() {
    setState(() => _isProjectDropdownOpen = true);
    final entry = buildAnchoredOverlay(
      context: context,
      link: _composerProjectLink,
      onDismiss: () {
        setState(() => _isProjectDropdownOpen = false);
        _closeAllOverlays();
      },
      child: _buildProjectDropdown(),
    );
    _showOverlay(entry);
  }

  Widget _buildProjectDropdown() {
    final store = ref.read(appStoreProvider);
    return ProjectDropdown(
      projects: store.projects,
      isAddingProject: _isAddingProject,
      newProjectName: _newProjectName,
      onNameChanged: (v) => setState(() => _newProjectName = v),
      onStartCreate: () => setState(() => _isAddingProject = true),
      onCancelCreate: () => setState(() {
        _isAddingProject = false;
        _newProjectName = '';
      }),
      onSelectProject: (id) {
        setState(() {
          _selectedProjectId = id;
          _isProjectDropdownOpen = false;
        });
        _closeAllOverlays();
      },
      onCommitCreate: () {
        final store = ref.read(appStoreProvider);
        final style = ProjectStyles.all[Random().nextInt(ProjectStyles.all.length)];
        store.addProject(_newProjectName.trim(), style);
        final newProject = store.projects.last;
        setState(() {
          _selectedProjectId = newProject.id;
          _isAddingProject = false;
          _newProjectName = '';
          _isProjectDropdownOpen = false;
        });
        _closeAllOverlays();
      },
    );
  }

  void _openPresetPicker(String taskId, LayerLink link) {
    setState(() => _activePresetTaskId = taskId);
    final store = ref.read(appStoreProvider);
    final entry = buildAnchoredOverlay(
      context: context,
      link: link,
      onDismiss: () {
        setState(() => _activePresetTaskId = null);
        _closeAllOverlays();
      },
      targetAnchor: Alignment.bottomRight,
      followerAnchor: Alignment.topRight,
      child: PresetPicker(
        lastUsedPreset: store.lastUsedPreset,
        onSelect: (mins) {
          ref.read(appStoreProvider).setLastUsedPreset(mins);
          _closeAllOverlays();
          setState(() => _activePresetTaskId = null);
          context.go('/focus/$taskId?preset=$mins');
        },
      ),
    );
    _showOverlay(entry);
  }

  void _openOverflowMenu(String taskId, LayerLink link) {
    setState(() => _activeMenuTaskId = taskId);
    final entry = buildAnchoredOverlay(
      context: context,
      link: link,
      onDismiss: () {
        setState(() => _activeMenuTaskId = null);
        _closeAllOverlays();
      },
      targetAnchor: Alignment.bottomRight,
      followerAnchor: Alignment.topRight,
      child: TaskOverflowMenu(
        onDelete: () {
          ref.read(appStoreProvider).deleteTask(taskId);
          _closeAllOverlays();
          setState(() => _activeMenuTaskId = null);
        },
      ),
    );
    _showOverlay(entry);
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(appStoreProvider);
    final tasks = store.tasks;
    final projects = store.projects;
    final sessions = store.sessions;
    final lastUsedPreset = store.lastUsedPreset;

    final now = DateTime.now();
    final todaySessions = sessions.where((s) =>
        s.completedAt.year == now.year &&
        s.completedAt.month == now.month &&
        s.completedAt.day == now.day).toList();
    final todayFocusTime = todaySessions.fold<int>(0, (sum, s) => sum + s.duration);

    final sortedTasks = List<Task>.from(tasks)
      ..sort((a, b) {
        if (a.completed != b.completed) return a.completed ? 1 : -1;
        return b.createdAt.compareTo(a.createdAt);
      });

    final filteredTasks = sortedTasks.where((t) {
      if (_searchQuery.isNotEmpty && !t.title.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      if (_filterProjectId != 'all' && t.projectId != _filterProjectId) return false;
      return true;
    }).toList();

    final nextFocusTask = sortedTasks.where((t) => !t.completed).firstOrNull;
    final hasCompleted = tasks.any((t) => t.completed);
    final showSearchFilter = tasks.length >= 5;
    final isComposing = _newTaskController.text.isNotEmpty;

    final summary = '${formatDuration(todayFocusTime)} focused \u2022 ${todaySessions.length} sessions completed';
    final selectedProject = _selectedProjectId != null ? store.findProject(_selectedProjectId) : null;

    return PageEntryAnimation(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TodayHeader(summary: summary),
            const SizedBox(height: AppSpacing.xxl),
            if (nextFocusTask != null) ...[
              CompositedTransformTarget(
                link: _presetLinks.putIfAbsent('hero', () => LayerLink()),
                child: NextFocusHero(
                  title: nextFocusTask.title,
                  lastUsedPreset: lastUsedPreset,
                  onStart: () => context.go('/focus/${nextFocusTask.id}?preset=$lastUsedPreset'),
                  onPresetTap: () => _openPresetPicker(nextFocusTask.id, _presetLinks['hero']!),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
            CompositedTransformTarget(
              link: _composerProjectLink,
              child: TaskComposer(
                controller: _newTaskController,
                focusNode: _composerFocusNode,
                onSubmit: _addTask,
                onProjectTap: _openProjectDropdown,
                selectedProjectName: selectedProject?.name,
                selectedProjectStyle: selectedProject?.style,
                showProjectRow: isComposing && _postCreate == null,
                showAddButton: isComposing,
              ),
            ),
            if (_postCreate != null) ...[
              const SizedBox(height: AppSpacing.sm),
              PostCreateAffordance(
                title: _postCreate!.title,
                lastUsedPreset: lastUsedPreset,
                onDismiss: () => setState(() => _postCreate = null),
                onStart: () {
                  final id = _postCreate!.id;
                  setState(() => _postCreate = null);
                  context.go('/focus/$id?preset=$lastUsedPreset');
                },
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            if (showSearchFilter) ...[
              SearchFilterBar(
                searchQuery: _searchQuery,
                onSearchChanged: (q) => setState(() => _searchQuery = q),
                activeProjectId: _filterProjectId,
                projects: projects,
                onProjectChanged: (id) => setState(() => _filterProjectId = id),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (hasCompleted)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      final completed = tasks.where((t) => t.completed).toList();
                      for (final t in completed) {
                        ref.read(appStoreProvider).deleteTask(t.id);
                      }
                    },
                    child: Text('Clear completed', style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary)),
                  ),
                ),
              ),
            if (filteredTasks.isEmpty)
              const EmptyTaskState()
            else
              ...filteredTasks.map((task) {
                final project = store.findProject(task.projectId);
                final presetLink = _presetLinks.putIfAbsent(task.id, () => LayerLink());
                final menuLink = _menuLinks.putIfAbsent(task.id, () => LayerLink());
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: CompositedTransformTarget(
                    link: presetLink,
                    child: CompositedTransformTarget(
                      link: menuLink,
                      child: TaskRow(
                        task: task,
                        project: project,
                        lastUsedPreset: lastUsedPreset,
                        onToggle: () => store.toggleTask(task.id),
                        onStart: () => context.go('/focus/${task.id}?preset=$lastUsedPreset'),
                        onPresetTap: () => _openPresetPicker(task.id, presetLink),
                        onMenuTap: () => _openOverflowMenu(task.id, menuLink),
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}
