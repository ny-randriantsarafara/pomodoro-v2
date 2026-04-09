import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

/// Form for editing a task title and project assignment (including inline
/// project creation).
class TaskEditor extends StatefulWidget {
  final String initialTitle;
  final String? initialProjectId;
  final List<Project> projects;
  final Future<void> Function(String title, String? projectId) onSave;
  final VoidCallback onCancel;
  final Future<String> Function(String name) onCreateProject;

  const TaskEditor({
    super.key,
    required this.initialTitle,
    required this.initialProjectId,
    required this.projects,
    required this.onSave,
    required this.onCancel,
    required this.onCreateProject,
  });

  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _newProjectNameController;
  String? _projectId;
  bool _isCreatingProject = false;
  bool _saving = false;
  bool _creatingProject = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _newProjectNameController = TextEditingController();
    _projectId = widget.initialProjectId;
    _titleController.addListener(() => setState(() {}));
    _newProjectNameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _newProjectNameController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _titleController.text.trim().isNotEmpty && !_saving;

  Future<void> _submit() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(
        _titleController.text.trim(),
        _projectId,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _commitNewProject() async {
    final name = _newProjectNameController.text.trim();
    if (name.isEmpty || _creatingProject) return;
    setState(() => _creatingProject = true);
    try {
      final id = await widget.onCreateProject(name);
      if (!mounted) return;
      setState(() {
        _projectId = id;
        _isCreatingProject = false;
        _newProjectNameController.clear();
      });
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create project: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _creatingProject = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit task', style: AppTypography.headingLg),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('task_editor_title'),
              controller: _titleController,
              style: AppTypography.bodyBase.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Task title',
                hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textTertiary),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadii.borderSm,
                  borderSide: BorderSide(color: AppColors.neutral200),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Project', style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            _projectRow('No Project', null),
            ...widget.projects.map(
              (p) => _projectRow(p.name, p.id, style: p.style),
            ),
            const Divider(height: AppSpacing.lg, color: AppColors.surfaceBorderLight),
            if (_isCreatingProject)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _newProjectNameController,
                      autofocus: true,
                      style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Project name…',
                        hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textTertiary),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: AppRadii.borderSm,
                          borderSide: BorderSide(color: AppColors.neutral200),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _creatingProject
                              ? null
                              : () => setState(() {
                                    _isCreatingProject = false;
                                    _newProjectNameController.clear();
                                  }),
                          child: Text(
                            'Cancel',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _newProjectNameController.text.trim().isNotEmpty &&
                                  !_creatingProject
                              ? _commitNewProject
                              : null,
                          child: Text(
                            'Add Project',
                            style: AppTypography.bodySm.copyWith(
                              color: _newProjectNameController.text.trim().isNotEmpty &&
                                      !_creatingProject
                                  ? AppColors.neutral900
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: () => setState(() => _isCreatingProject = true),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    'Create new project',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                TextButton(
                  onPressed: _saving ? null : widget.onCancel,
                  child: Text(
                    'Cancel',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  key: const Key('task_editor_save'),
                  onPressed: _canSave ? _submit : null,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Save',
                          style: AppTypography.bodySm.copyWith(color: AppColors.white),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _projectRow(String label, String? id, {ProjectStyle? style}) {
    final selected = _projectId == id;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: GestureDetector(
        onTap: () => setState(() => _projectId = id),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.neutral100 : Colors.transparent,
            borderRadius: AppRadii.borderSm,
            border: Border.all(
              color: selected ? AppColors.neutral300 : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              if (style != null)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: style.foreground,
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                label,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
