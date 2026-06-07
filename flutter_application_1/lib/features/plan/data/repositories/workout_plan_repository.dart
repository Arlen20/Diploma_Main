import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../profile_settings/domain/entities/user_profile.dart';
import '../../domain/entities/workout_plan_entry.dart';

class WorkoutPlanRepository {
  WorkoutPlanRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _planCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('plans');
  }

  Future<List<WorkoutPlanEntry>> load() async {
    final user = _auth.currentUser;
    if (user == null) return const [];

    final snapshot = await _planCollection(user.uid).get();
    final items = snapshot.docs
        .map((doc) => WorkoutPlanEntry.fromJson(doc.id, doc.data()))
        .map(_withFallbackExercises)
        .toList(growable: false);

    final sorted = [...items]
      ..sort((a, b) {
        final byDay = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (byDay != 0) return byDay;
        return a.timeLabel.compareTo(b.timeLabel);
      });
    return sorted;
  }

  WorkoutPlanEntry _withFallbackExercises(WorkoutPlanEntry entry) {
    if (entry.exercises.isNotEmpty) return entry;

    final lowerTitle = entry.title.toLowerCase();
    final fallbackExercises = switch (lowerTitle) {
      'full body cardio' ||
      'fat burn circuit' => [_jumpingJacks, _squats, _mountainClimbers],
      'lower body burn' ||
      'lower body conditioning' => [_lunges, _gluteBridge, _highKnees],
      'core + cardio' ||
      'core + hiit' => [_crunches, _plankShoulderTaps, _burpees],
      'full body hiit' ||
      'full body sweat' => [_squats, _pushUps, _mountainClimbers],
      'push' ||
      'upper body push' => [_pushUps, _closeGripPushUps, _plankShoulderTaps],
      'legs' || 'lower body strength' => [_squats, _lunges, _gluteBridge],
      'pull / back' ||
      'back + biceps pull' => [_superman, _backExtensions, _sidePlank],
      'core' || 'core stability' => [_crunches, _plankShoulderTaps, _sidePlank],
      'full body strength' ||
      'full body hypertrophy' => [_squats, _pushUps, _lunges],
      'cardio' ||
      'mobility + cardio' => [_jumpingJacks, _highKnees, _mountainClimbers],
      'lower body' || 'lower body focus' => [_lunges, _gluteBridge, _squats],
      'upper + core' => [_pushUps, _plankShoulderTaps, _sidePlank],
      'mobility / back' => [_superman, _gluteBridge, _sidePlank],
      'mixed circuit' => [_squats, _burpees, _crunches],
      _ => [_squats, _pushUps, _crunches],
    };

    return entry.copyWith(exercises: fallbackExercises);
  }

  Future<List<WorkoutPlanEntry>> generate(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) return const [];

    final generated = _buildPrototypePlan(profile);
    final batch = _firestore.batch();
    final collection = _planCollection(user.uid);
    final existing = await collection.get();

    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }

    for (final item in generated) {
      final doc = collection.doc(item.id);
      batch.set(doc, item.toJson());
    }

    await batch.commit();
    return generated;
  }

  Future<void> toggleCompleted(String id, bool completed) async {
    final user = _auth.currentUser;
    if (user == null || id.isEmpty) return;

    await _planCollection(
      user.uid,
    ).doc(id).set({'completed': completed}, SetOptions(merge: true));
  }

  List<WorkoutPlanEntry> _buildPrototypePlan(UserProfile profile) {
    final preferredDays = profile.preferredTrainingDays.clamp(3, 6);
    final selectedDays = _selectTrainingDays(preferredDays);
    final templates = _templatesForGoal(profile.goal, profile.activityLevel);

    return List.generate(selectedDays.length, (index) {
      final template = templates[index % templates.length];
      final day = selectedDays[index];
      return WorkoutPlanEntry(
        id: 'day_${day}_$index',
        dayOfWeek: day,
        title: template.title,
        timeLabel: template.timeLabel,
        subtitle: template.subtitleFor(profile),
        focus: template.focus,
        completed: false,
        generator: 'mock_ai_v1',
        exercises: template.exercises,
      );
    });
  }

  List<int> _selectTrainingDays(int count) {
    const rankedDays = <int>[
      DateTime.monday,
      DateTime.tuesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.wednesday,
    ];
    return rankedDays.take(count).toList(growable: false);
  }

  List<_PlanTemplate> _templatesForGoal(String goal, String activityLevel) {
    final lowerGoal = goal.toLowerCase();
    if (lowerGoal.contains('lose')) {
      return [
        _PlanTemplate(
          title: 'Full Body Cardio',
          timeLabel: '07:30',
          focus: 'cardio',
          subtitle: 'Low-rest cardio and strength work for calorie burn.',
          exercises: [_jumpingJacks, _squats, _mountainClimbers],
        ),
        _PlanTemplate(
          title: 'Lower Body Burn',
          timeLabel: '18:00',
          focus: 'legs',
          subtitle: 'Leg and glute work with a cardio finisher.',
          exercises: [_lunges, _gluteBridge, _highKnees],
        ),
        _PlanTemplate(
          title: 'Core + Cardio',
          timeLabel: '19:00',
          focus: 'core',
          subtitle: 'Core control mixed with higher-intensity conditioning.',
          exercises: [_crunches, _plankShoulderTaps, _burpees],
        ),
        _PlanTemplate(
          title: 'Full Body HIIT',
          timeLabel: '17:30',
          focus: 'full body',
          subtitle: 'Fast full-body circuit with short rest blocks.',
          exercises: [_squats, _pushUps, _mountainClimbers],
        ),
        _PlanTemplate(
          title: 'Legs + Core',
          timeLabel: '18:30',
          focus: 'legs',
          subtitle: 'Lower-body strength with simple core work.',
          exercises: [_gluteBridge, _lunges, _crunches],
        ),
        _PlanTemplate(
          title: 'Cardio Finisher',
          timeLabel: '11:00',
          focus: 'cardio',
          subtitle: 'Short cardio session to finish the training week.',
          exercises: [_highKnees, _jumpingJacks, _burpees],
        ),
      ];
    }

    if (lowerGoal.contains('gain')) {
      return [
        _PlanTemplate(
          title: 'Push',
          timeLabel: '18:00',
          focus: 'upper body',
          subtitle:
              'Chest, triceps, and shoulder stability with controlled reps.',
          exercises: [_pushUps, _closeGripPushUps, _plankShoulderTaps],
        ),
        _PlanTemplate(
          title: 'Legs',
          timeLabel: '17:30',
          focus: 'legs',
          subtitle: 'Compound lower-body work for strength and muscle gain.',
          exercises: [_squats, _lunges, _gluteBridge],
        ),
        _PlanTemplate(
          title: 'Pull / Back',
          timeLabel: '18:30',
          focus: 'back',
          subtitle: 'Back-extension work using the available bodyweight video.',
          exercises: [_superman, _backExtensions, _sidePlank],
        ),
        _PlanTemplate(
          title: 'Core',
          timeLabel: '11:00',
          focus: 'core',
          subtitle: 'Controlled core strength and stability work.',
          exercises: [_crunches, _plankShoulderTaps, _sidePlank],
        ),
        _PlanTemplate(
          title: 'Full Body Strength',
          timeLabel: '17:00',
          focus: 'full body',
          subtitle: 'Balanced strength day with reps instead of long timers.',
          exercises: [_squats, _pushUps, _lunges],
        ),
        _PlanTemplate(
          title: 'Glutes + Stability',
          timeLabel: '12:00',
          focus: 'legs',
          subtitle: 'Glute strength and core stability with controlled tempo.',
          exercises: [_gluteBridge, _squats, _sidePlank],
        ),
      ];
    }

    final mobilityNote = activityLevel == 'Low'
        ? 'Balanced with easier recovery pacing to keep adherence high.'
        : 'Balanced routine that supports consistency without overload.';

    return [
      _PlanTemplate(
        title: 'Full Body',
        timeLabel: '18:00',
        focus: 'full body',
        subtitle: 'Compound movement session to maintain strength and energy.',
        exercises: [_squats, _pushUps, _crunches],
      ),
      _PlanTemplate(
        title: 'Cardio',
        timeLabel: '08:00',
        focus: 'cardio',
        subtitle: 'Simple cardio work for conditioning and consistency.',
        exercises: [_jumpingJacks, _highKnees, _mountainClimbers],
      ),
      _PlanTemplate(
        title: 'Lower Body',
        timeLabel: '19:00',
        focus: 'legs',
        subtitle: 'Balanced leg and glute session.',
        exercises: [_lunges, _gluteBridge, _squats],
      ),
      _PlanTemplate(
        title: 'Upper + Core',
        timeLabel: '17:30',
        focus: 'upper body',
        subtitle: mobilityNote,
        exercises: [_pushUps, _plankShoulderTaps, _sidePlank],
      ),
      _PlanTemplate(
        title: 'Mobility / Back',
        timeLabel: '08:30',
        focus: 'mobility',
        subtitle: 'Light posterior-chain and stability work.',
        exercises: [_superman, _gluteBridge, _sidePlank],
      ),
      _PlanTemplate(
        title: 'Mixed Circuit',
        timeLabel: '11:00',
        focus: 'full body',
        subtitle: 'Mixed strength and cardio work to close the week.',
        exercises: [_squats, _burpees, _crunches],
      ),
    ];
  }

  static const _squats = WorkoutExercise(
    name: 'Squats',
    assetPath: 'assets/videos/Squats.mp4',
    instruction: 'Keep chest up and knees tracking over toes.',
    mode: WorkoutExerciseMode.reps,
    sets: 3,
    reps: 12,
    durationSeconds: null,
    restSeconds: 45,
  );

  static const _pushUps = WorkoutExercise(
    name: 'Push-ups',
    assetPath: 'assets/videos/Push-ups.mp4',
    instruction: 'Keep a straight body line and lower with control.',
    mode: WorkoutExerciseMode.reps,
    sets: 3,
    reps: 8,
    durationSeconds: null,
    restSeconds: 60,
  );

  static const _closeGripPushUps = WorkoutExercise(
    name: 'Close-grip push-ups',
    assetPath: 'assets/videos/Push-ups.mp4',
    instruction: 'Keep elbows closer to the body to bias triceps.',
    mode: WorkoutExerciseMode.reps,
    sets: 3,
    reps: 8,
    durationSeconds: null,
    restSeconds: 60,
  );

  static const _lunges = WorkoutExercise(
    name: 'Lunges',
    assetPath: 'assets/videos/Lunges2.mp4',
    instruction: 'Step smoothly and keep the front knee stable.',
    mode: WorkoutExerciseMode.reps,
    sets: 3,
    reps: 10,
    durationSeconds: null,
    restSeconds: 45,
  );

  static const _gluteBridge = WorkoutExercise(
    name: 'Glute bridge',
    assetPath: 'assets/videos/Glute_bridge.mp4',
    instruction: 'Squeeze glutes at the top and keep ribs down.',
    mode: WorkoutExerciseMode.reps,
    sets: 3,
    reps: 15,
    durationSeconds: null,
    restSeconds: 40,
  );

  static const _crunches = WorkoutExercise(
    name: 'Crunches',
    assetPath: 'assets/videos/Crunches.mp4',
    instruction: 'Lift shoulders with control and avoid pulling the neck.',
    mode: WorkoutExerciseMode.reps,
    sets: 3,
    reps: 15,
    durationSeconds: null,
    restSeconds: 35,
  );

  static const _superman = WorkoutExercise(
    name: 'Superman',
    assetPath: 'assets/videos/Superman.mp4',
    instruction: 'Lift arms and legs gently while keeping the neck neutral.',
    mode: WorkoutExerciseMode.reps,
    sets: 3,
    reps: 12,
    durationSeconds: null,
    restSeconds: 40,
  );

  static const _backExtensions = WorkoutExercise(
    name: 'Back extensions',
    assetPath: 'assets/videos/Superman.mp4',
    instruction: 'Lift the chest gently and squeeze the upper back.',
    mode: WorkoutExerciseMode.reps,
    sets: 3,
    reps: 12,
    durationSeconds: null,
    restSeconds: 40,
  );

  static const _jumpingJacks = WorkoutExercise(
    name: 'Jumping jacks',
    assetPath: 'assets/videos/Jumping_jacks.mp4',
    instruction: 'Move rhythmically and land softly.',
    mode: WorkoutExerciseMode.timed,
    sets: 1,
    reps: null,
    durationSeconds: 30,
    restSeconds: 20,
  );

  static const _highKnees = WorkoutExercise(
    name: 'High knees',
    assetPath: 'assets/videos/High-knees.mp4',
    instruction: 'Drive knees up and keep the torso tall.',
    mode: WorkoutExerciseMode.timed,
    sets: 1,
    reps: null,
    durationSeconds: 30,
    restSeconds: 20,
  );

  static const _mountainClimbers = WorkoutExercise(
    name: 'Mountain climbers',
    assetPath: 'assets/videos/Mountain-climbers2.mp4',
    instruction: 'Keep shoulders over wrists and hips steady.',
    mode: WorkoutExerciseMode.timed,
    sets: 1,
    reps: null,
    durationSeconds: 30,
    restSeconds: 25,
  );

  static const _plankShoulderTaps = WorkoutExercise(
    name: 'Plank shoulder taps',
    assetPath: 'assets/videos/Plank-shoulder-taps.mp4',
    instruction: 'Tap shoulders without rocking the hips.',
    mode: WorkoutExerciseMode.timed,
    sets: 1,
    reps: null,
    durationSeconds: 30,
    restSeconds: 25,
  );

  static const _burpees = WorkoutExercise(
    name: 'Burpees',
    assetPath: 'assets/videos/Burpees.mp4',
    instruction: 'Move at a safe pace and keep landings soft.',
    mode: WorkoutExerciseMode.timed,
    sets: 1,
    reps: null,
    durationSeconds: 25,
    restSeconds: 35,
  );

  static const _sidePlank = WorkoutExercise(
    name: 'Side plank',
    assetPath: 'assets/videos/Side-plank.mp4',
    instruction: 'Keep hips lifted and body in one straight line.',
    mode: WorkoutExerciseMode.timed,
    sets: 1,
    reps: null,
    durationSeconds: 25,
    restSeconds: 25,
  );
}

class _PlanTemplate {
  final String title;
  final String timeLabel;
  final String subtitle;
  final String focus;
  final List<WorkoutExercise> exercises;

  const _PlanTemplate({
    required this.title,
    required this.timeLabel,
    required this.subtitle,
    required this.focus,
    required this.exercises,
  });

  String subtitleFor(UserProfile profile) {
    final activityNote = switch (profile.activityLevel) {
      'Low' => 'Lower intensity and longer recovery.',
      'High' => 'Higher volume and intensity for your activity level.',
      _ => 'Moderate intensity matched to your current routine.',
    };

    return '$subtitle $activityNote';
  }
}
