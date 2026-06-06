import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../domain/entities/workout_plan_entry.dart';
import '../state/workout_plan_provider.dart';

class TrainingSessionPage extends ConsumerStatefulWidget {
  final WorkoutPlanEntry planEntry;

  const TrainingSessionPage({super.key, required this.planEntry});

  @override
  ConsumerState<TrainingSessionPage> createState() =>
      _TrainingSessionPageState();
}

class _TrainingSessionPageState extends ConsumerState<TrainingSessionPage> {
  static const _fallbackExercises = [
    WorkoutExercise(
      name: 'Squats',
      assetPath: 'assets/videos/Squats.mp4',
      instruction: 'Keep chest up and knees tracking over toes.',
      mode: WorkoutExerciseMode.reps,
      sets: 3,
      reps: 12,
      durationSeconds: null,
      restSeconds: 45,
    ),
    WorkoutExercise(
      name: 'Push-ups',
      assetPath: 'assets/videos/Push-ups.mp4',
      instruction: 'Keep a straight body line and lower with control.',
      mode: WorkoutExerciseMode.reps,
      sets: 3,
      reps: 8,
      durationSeconds: null,
      restSeconds: 60,
    ),
  ];

  VideoPlayerController? _controller;
  Timer? _timer;
  int _currentIndex = 0;
  int _secondsLeft = 0;
  bool _isResting = false;
  bool _isFinishing = false;

  List<WorkoutExercise> get _exercises => widget.planEntry.exercises.isEmpty
      ? _fallbackExercises
      : widget.planEntry.exercises;

  WorkoutExercise get _currentExercise => _exercises[_currentIndex];

  @override
  void initState() {
    super.initState();
    _secondsLeft = _currentExercise.durationSeconds ?? 0;
    _loadVideo();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadVideo() async {
    final oldController = _controller;
    final controller = VideoPlayerController.asset(_currentExercise.assetPath);
    _controller = controller;
    await oldController?.dispose();

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isFinishing) return;
      if (!_isResting && !_currentExercise.isTimed) return;
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
        return;
      }
      _advanceSession();
    });
  }

  Future<void> _advanceSession() async {
    if (_isResting) {
      setState(() {
        _isResting = false;
        _currentIndex++;
        _secondsLeft = _currentExercise.durationSeconds ?? 0;
      });
      await _loadVideo();
      return;
    }

    final isLastExercise = _currentIndex == _exercises.length - 1;
    if (isLastExercise) {
      await _finishSession();
      return;
    }

    _startRest();
  }

  Future<void> _startRest() async {
    setState(() {
      _isResting = true;
      _secondsLeft = _currentExercise.restSeconds;
    });
    await _controller?.pause();
  }

  Future<void> _finishSession() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);
    _timer?.cancel();
    await _controller?.pause();
    if (!widget.planEntry.completed) {
      await ref
          .read(workoutPlanProvider.notifier)
          .toggleCompleted(widget.planEntry);
    }
    if (!mounted) return;
    context.go(AppRoutes.trainingSuccess);
  }

  @override
  Widget build(BuildContext context) {
    final progressLabel = '${_currentIndex + 1}/${_exercises.length} exercises';
    final timerLabel = _secondsLeft.toString().padLeft(2, '0');
    final title = _isResting ? 'Rest' : _currentExercise.name;
    final subtitle = _isResting
        ? 'Next: ${_exercises[_currentIndex + 1].name}'
        : _currentExercise.instruction;
    final targetLabel = _currentExercise.isTimed
        ? '${_currentExercise.durationSeconds ?? 30} seconds'
        : '${_currentExercise.sets} sets x ${_currentExercise.reps ?? 10} reps';
    final setLabel = _currentExercise.isTimed ? 'Timed exercise' : targetLabel;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go(AppRoutes.schedule),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      ),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.planEntry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  progressLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  targetLabel,
                  style: const TextStyle(
                    color: Color(0xFFF4F0B6),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 34,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: _isResting
                      ? _RestView(secondsLeft: timerLabel)
                      : _VideoView(controller: _controller),
                ),
                const SizedBox(height: 18),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          _isResting || _currentExercise.isTimed
                              ? timerLabel
                              : '${_currentExercise.reps ?? _currentExercise.sets}',
                          style: const TextStyle(
                            color: Color(0xFF24134D),
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isResting ? 'Recover' : setLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isResting
                                  ? 'Breathe, reset posture, prepare for the next exercise.'
                                  : _currentExercise.isTimed
                                  ? 'Follow the looping video until the timer ends.'
                                  : 'Follow the form guide, complete all sets, then continue.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.66),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: _isFinishing ? null : _advanceSession,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(
                          _currentIndex == _exercises.length - 1 && !_isResting
                              ? Icons.check_rounded
                              : _currentExercise.isTimed && !_isResting
                              ? Icons.skip_next_rounded
                              : Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoView extends StatelessWidget {
  final VideoPlayerController? controller;

  const _VideoView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final activeController = controller;
    final isReady = activeController?.value.isInitialized ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        color: Colors.black.withValues(alpha: 0.28),
        child: isReady
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: activeController!.value.size.width,
                  height: activeController.value.size.height,
                  child: VideoPlayer(activeController),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
      ),
    );
  }
}

class _RestView extends StatelessWidget {
  final String secondsLeft;

  const _RestView({required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.self_improvement_rounded,
              color: Colors.white,
              size: 72,
            ),
            const SizedBox(height: 22),
            Text(
              secondsLeft,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'seconds rest',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
