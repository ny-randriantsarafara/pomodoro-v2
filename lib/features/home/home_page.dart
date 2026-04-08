import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../shared/logging/app_logger.dart';
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
import 'widgets/task_editor.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appStoreProvider).loadData();
    });
  }

  @override
  void dispose() {
    _postCreateTimer?.cancel();
    _closeAllOverlays();
    _newTaskController.dispose();
    _composerFocusNode.dispose();
    super.dispose();
  }

  void _closeAllOverlays() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    _activePresetTaskId = null;
    _activeMenuTaskId = null;
  }

  void _showOverlay(OverlayEntry entry) {
    _closeAllOverlays();
    _currentOverlay = entry;
    Overlay.of(context).insert(entry);
  }

  Future<void> _addTask() async {
    final title = _newTaskController.text.trim();
    if (title.isEmpty) return;
    final store = ref.read(appStoreProvider);
    await store.addTask(title, projectId: _selectedProjectId);
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

  Future<void> _openProjectDropdown() async {
    final store = ref.read(appStoreProvider);
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 600;
    final newProjectNameController = TextEditingController();
    var isAddingProject = false;

    Widget buildPicker(BuildContext modalContext, void Function(void Function()) setModalState) {
      return ProjectDropdown(
        projects: ref.read(appStoreProvider).projects,
        isAddingProject: isAddingProject,
        newProjectNameController: newProjectNameController,
        onNameChanged: (_) => setModalState(() {}),
        onStartCreate: () {
          newProjectNameController.clear();
          setModalState(() => isAddingProject = true);
        },
        onCancelCreate: () {
          newProjectNameController.clear();
          setModalState(() => isAddingProject = false);
        },
        onSelectProject: (id) {
          if (!mounted) return;
          setState(() => _selectedProjectId = id);
          Navigator.of(modalContext).pop();
        },
        onCommitCreate: () async {
          final style =
              ProjectStyles.all[Random().nextInt(ProjectStyles.all.length)];
          try {
            await store.addProject(newProjectNameController.text.trim(), style);
          } catch (e, stackTrace) {
            AppLogger.error(
              domain: 'composer_project_picker',
              event: 'project_create_failed',
              error: e,
              stackTrace: stackTrace,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not create project.')),
              );
            }
            return;
          }
          final newProject = store.projects.last;
          if (!mounted || !modalContext.mounted) return;
          setState(() => _selectedProjectId = newProject.id);
          Navigator.of(modalContext).pop();
        },
      );
    }

    try {
      if (wide) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: buildPicker(dialogContext, setModalState),
                  ),
                );
              },
            );
          },
        );
      } else {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) {
            return SafeArea(
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
                    ),
                    child: buildPicker(sheetContext, setModalState),
                  );
                },
              ),
            );
          },
        );
      }
    } finally {
      newProjectNameController.dispose();
    }
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

  Future<void> _openTaskEditor(Task task) async {
    AppLogger.info(
      domain: 'task_editor',
      event: 'opened',
      context: {'task_id': task.id},
    );
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 600;

    Future<String> createProject(String name) async {
      final store = ref.read(appStoreProvider);
      final style =
          ProjectStyles.all[Random().nextInt(ProjectStyles.all.length)];
      try {
        await store.addProject(name, style);
      } on Object catch (error, stackTrace) {
        AppLogger.error(
          domain: 'task_editor',
          event: 'inline_project_create_failed',
          context: {'task_id': task.id},
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
      AppLogger.info(
        domain: 'task_editor',
        event: 'inline_project_created',
        context: {'task_id': task.id},
      );
      return store.projects.last.id;
    }

    Future<void> persistEdit(
      String title,
      String? projectId,
      void Function() close,
    ) async {
      final store = ref.read(appStoreProvider);
      final clearProject = task.projectId != null && projectId == null;
      try {
        await store.updateTask(
          id: task.id,
          title: title,
          projectId: clearProject ? null : projectId,
          clearProjectId: clearProject,
        );
        AppLogger.info(
          domain: 'task_editor',
          event: 'task_update_succeeded',
          context: {'task_id': task.id},
        );
        if (!mounted) return;
        close();
      } on Object catch (error, stackTrace) {
        AppLogger.error(
          domain: 'task_editor',
          event: 'task_update_failed',
          context: {'task_id': task.id},
          error: error,
          stackTrace: stackTrace,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not save task.')),
          );
        }
      }
    }

    if (!mounted) return;

    if (wide) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TaskEditor(
                initialTitle: task.title,
                initialProjectId: task.projectId,
                projects: ref.read(appStoreProvider).projects,
                onCancel: () => Navigator.of(dialogContext).pop(),
                onSave: (title, projectId) => persistEdit(
                  title,
                  projectId,
                  () => Navigator.of(dialogContext).pop(),
                ),
                onCreateProject: createProject,
              ),
            ),
          );
        },
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final inset = MediaQuery.viewInsetsOf(sheetContext).bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: inset),
          child: TaskEditor(
            initialTitle: task.title,
            initialProjectId: task.projectId,
            projects: ref.read(appStoreProvider).projects,
            onCancel: () => Navigator.of(sheetContext).pop(),
            onSave: (title, projectId) => persistEdit(
              title,
              projectId,
              () => Navigator.of(sheetContext).pop(),
            ),
            onCreateProject: createProject,
          ),
        );
      },
    );
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
        onEdit: () {
          final task = ref.read(appStoreProvider).findTask(taskId);
          if (task == null) return;
          _closeAllOverlays();
          setState(() => _activeMenuTaskId = null);
          _openTaskEditor(task);
        },
        onDelete: () async {
          await ref.read(appStoreProvider).deleteTask(taskId);
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
                onProjectTap: () {
                  _openProjectDropdown();
                },
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
                    onTap: () async {
                      final completed = tasks.where((t) => t.completed).toList();
                      for (final t in completed) {
                        await ref.read(appStoreProvider).deleteTask(t.id);
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
                        onToggle: () async => await store.toggleTask(task.id),
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
