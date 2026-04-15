import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../alerts/application/session_alert_coordinator.dart';
import '../../store/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import 'widgets/celebration_state.dart';
import 'widgets/recovery_state.dart';
import 'widgets/break_actions.dart';

enum BreakPhase { celebration, recovery }

class BreakTimerPage extends ConsumerStatefulWidget {
  final String taskId;
  final int breakMinutes;
  final bool justCompleted;

  const BreakTimerPage({
    super.key,
    required this.taskId,
    required this.breakMinutes,
    required this.justCompleted,
  });

  @override
  ConsumerState<BreakTimerPage> createState() => _BreakTimerPageState();
}

class _BreakTimerPageState extends ConsumerState<BreakTimerPage>
    with TickerProviderStateMixin {
  late final int initialTime;
  late int timeLeft;
  late BreakPhase phase;
  Timer? celebrationTimer;
  Timer? ticker;
  bool _navigated = false;

  late final AnimationController pageController;

  @override
  void initState() {
    super.initState();
    initialTime = widget.breakMinutes * 60;
    timeLeft = initialTime;
    phase = widget.justCompleted ? BreakPhase.celebration : BreakPhase.recovery;

    pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    pageController.forward();

    if (phase == BreakPhase.celebration) {
      celebrationTimer = Timer(AppMotion.celebrationDelay, () {
        if (mounted) {
          setState(() => phase = BreakPhase.recovery);
          _scheduleBreakAlert();
          _startTicker();
        }
      });
    } else {
      _scheduleBreakAlert();
      _startTicker();
    }
  }

  void _scheduleBreakAlert() {
    final endsAt = DateTime.now().add(Duration(seconds: timeLeft));
    ref
        .read(sessionAlertCoordinatorProvider)
        .onSessionStarted(SessionType.breakTime, endsAt);
  }

  void _startTicker() {
    ticker?.cancel();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => timeLeft--);
      if (timeLeft <= 0) {
        setState(() => timeLeft = 0);
        ticker?.cancel();
        _goHome();
      }
    });
  }

  void _goHome() {
    if (_navigated) return;
    _navigated = true;
    ref
        .read(sessionAlertCoordinatorProvider)
        .onSessionCompleted(SessionType.breakTime);
    if (mounted) context.go('/');
  }

  void _handleContinue() {
    if (_navigated) return;
    _navigated = true;
    ref
        .read(sessionAlertCoordinatorProvider)
        .onSessionCancelledOrReset();
    final store = ref.read(appStoreProvider);
    final preset = store.lastUsedPreset;
    if (mounted) {
      context.go('/focus/${widget.taskId}?preset=$preset');
    }
  }

  @override
  void dispose() {
    celebrationTimer?.cancel();
    ticker?.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(appStoreProvider);
    final task = store.findTask(widget.taskId);
    final hasContinue = task != null && !task.completed;

    return Scaffold(
      backgroundColor: AppColors.breakBg,
      body: FadeTransition(
        opacity: pageController,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 700),
                child: phase == BreakPhase.celebration
                    ? CelebrationState(
                        key: const ValueKey('celebration'),
                        breakMinutes: widget.breakMinutes,
                      )
                    : RecoveryState(
                        key: const ValueKey('recovery'),
                        task: task,
                        timeLeft: timeLeft,
                        initialTime: initialTime,
                        actions: BreakActions(
                          task: task,
                          hasContinuePrimary: hasContinue,
                          onContinue: _handleContinue,
                          onBack: _goHome,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
