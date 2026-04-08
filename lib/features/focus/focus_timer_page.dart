import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/utils/format_helpers.dart';
import '../../store/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import 'widgets/focus_background.dart';
import 'widgets/focus_title_block.dart';
import 'widgets/focus_timer_ring.dart';
import 'widgets/focus_controls.dart';

enum FocusPhase { intro, active }

class FocusTimerPage extends ConsumerStatefulWidget {
  final String taskId;
  final int preset;

  const FocusTimerPage({
    super.key,
    required this.taskId,
    required this.preset,
  });

  @override
  ConsumerState<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends ConsumerState<FocusTimerPage>
    with TickerProviderStateMixin {
  late final int initialTime;
  late int timeLeft;
  bool isActive = false;
  FocusPhase phase = FocusPhase.intro;
  Timer? introTimer;
  Timer? ticker;
  bool _completed = false;

  late final AnimationController titleController;
  late final AnimationController timerController;
  late final AnimationController controlsController;

  @override
  void initState() {
    super.initState();
    initialTime = widget.preset * 60;
    timeLeft = initialTime;

    titleController = AnimationController(
      vsync: this,
      duration: AppMotion.introTitleDuration,
    );
    timerController = AnimationController(
      vsync: this,
      duration: AppMotion.introTimerDuration,
    );
    controlsController = AnimationController(
      vsync: this,
      duration: AppMotion.introControlsDuration,
    );

    titleController.forward();

    Future.delayed(AppMotion.introTimerDelay, () {
      if (mounted) timerController.forward();
    });

    Future.delayed(AppMotion.introControlsDelay, () {
      if (mounted) controlsController.forward();
    });

    introTimer = Timer(AppMotion.introPhaseDelay, () {
      if (mounted) {
        setState(() {
          phase = FocusPhase.active;
          isActive = true;
        });
        _startTicker();
      }
    });
  }

  void _startTicker() {
    ticker?.cancel();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isActive) return;
      setState(() {
        timeLeft--;
      });
      if (timeLeft <= 0) {
        setState(() => timeLeft = 0);
        ticker?.cancel();
        _handleComplete();
      }
    });
  }

  Future<void> _handleComplete() async {
    if (_completed) return;
    _completed = true;

    final store = ref.read(appStoreProvider);
    final task = store.findTask(widget.taskId);
    final project = task != null ? store.findProject(task.projectId) : null;

    await store.addSession(
      taskId: widget.taskId,
      taskTitle: task?.title ?? 'Unknown',
      projectName: project?.name,
      projectStyle: project?.style,
      preset: widget.preset,
      duration: initialTime,
    );

    final breakMins = breakMinutesForPreset(widget.preset);
    if (mounted) {
      context.go('/break/${widget.taskId}?mins=$breakMins&completed=true');
    }
  }

  void _handlePauseResume() {
    setState(() {
      isActive = !isActive;
    });
    if (isActive) {
      _startTicker();
    } else {
      ticker?.cancel();
    }
  }

  void _handleAbandon() {
    if (mounted) context.go('/');
  }

  Future<void> _handleSaveEnd() async {
    if (_completed) return;
    _completed = true;

    final store = ref.read(appStoreProvider);
    final task = store.findTask(widget.taskId);
    final project = task != null ? store.findProject(task.projectId) : null;
    final focusedDuration = initialTime - timeLeft;

    await store.addSession(
      taskId: widget.taskId,
      taskTitle: task?.title ?? 'Unknown',
      projectName: project?.name,
      projectStyle: project?.style,
      preset: widget.preset,
      duration: focusedDuration,
    );

    final breakMins = breakMinutesForPreset(widget.preset);
    if (mounted) {
      context.go('/break/${widget.taskId}?mins=$breakMins&completed=false');
    }
  }

  String get _phaseText {
    if (initialTime > 0) {
      final progress = (initialTime - timeLeft) / initialTime;
      if (progress < 0.1) return 'SETTLING IN';
      if (timeLeft < 60) return 'FINAL STRETCH';
    }
    return 'DEEP FOCUS';
  }

  @override
  void dispose() {
    introTimer?.cancel();
    ticker?.cancel();
    titleController.dispose();
    timerController.dispose();
    controlsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(appStoreProvider);
    final task = store.findTask(widget.taskId);

    if (task == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/');
      });
      return const SizedBox.shrink();
    }

    final project = store.findProject(task.projectId);
    final progress = initialTime > 0 ? (initialTime - timeLeft) / initialTime : 0.0;

    return Scaffold(
      backgroundColor: AppColors.focusBg,
      body: Stack(
        children: [
          FocusBackground(progress: progress, timeLeft: timeLeft),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    FocusTitleBlock(
                      title: task.title,
                      project: project,
                      showPhaseLabel: phase == FocusPhase.active,
                      phaseText: _phaseText,
                      animation: CurvedAnimation(
                        parent: titleController,
                        curve: AppMotion.focusIntroCurve,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.huge),
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: timerController,
                        curve: Curves.easeOut,
                      ),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                          CurvedAnimation(
                            parent: timerController,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: FocusTimerRing(
                          timeLeft: timeLeft,
                          initialTime: initialTime,
                          showProgress: phase == FocusPhase.active,
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                      child: FocusControls(
                        isActive: isActive,
                        disabled: phase == FocusPhase.intro,
                        onPrimary: _handlePauseResume,
                        onAbandon: _handleAbandon,
                        onSaveEnd: _handleSaveEnd,
                        animation: CurvedAnimation(
                          parent: controlsController,
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.huge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
