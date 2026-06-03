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
        .toList(growable: false);

    final sorted = [...items]
      ..sort((a, b) {
        final byDay = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (byDay != 0) return byDay;
        return a.timeLabel.compareTo(b.timeLabel);
      });
    return sorted;
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

    await _planCollection(user.uid).doc(id).set({
      'completed': completed,
    }, SetOptions(merge: true));
  }

  List<WorkoutPlanEntry> _buildPrototypePlan(UserProfile profile) {
    final preferredDays = profile.preferredTrainingDays.clamp(2, 6);
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
          title: 'Fat Burn Circuit',
          timeLabel: '07:30',
          focus: 'cardio',
          subtitle:
              'Intervals, bodyweight moves, and short rests to increase calorie burn.',
        ),
        _PlanTemplate(
          title: 'Lower Body Conditioning',
          timeLabel: '18:00',
          focus: 'legs',
          subtitle:
              'Lunges, squats, glute bridge, and finishers to build stamina.',
        ),
        _PlanTemplate(
          title: 'Core + HIIT',
          timeLabel: '19:00',
          focus: 'core',
          subtitle:
              'Short explosive rounds with core-focused recovery blocks.',
        ),
        _PlanTemplate(
          title: 'Full Body Sweat',
          timeLabel: '17:30',
          focus: 'full body',
          subtitle:
              'Metabolic full-body session to support weight-loss progress.',
        ),
      ];
    }

    if (lowerGoal.contains('gain')) {
      return [
        _PlanTemplate(
          title: 'Upper Body Push',
          timeLabel: '18:00',
          focus: 'upper body',
          subtitle:
              'Pressing volume for chest, shoulders, and triceps growth.',
        ),
        _PlanTemplate(
          title: 'Lower Body Strength',
          timeLabel: '17:30',
          focus: 'legs',
          subtitle:
              'Compound leg session to drive strength and muscle gain.',
        ),
        _PlanTemplate(
          title: 'Back + Biceps Pull',
          timeLabel: '18:30',
          focus: 'back',
          subtitle:
              'Rows, pull variations, and arm accessories for hypertrophy.',
        ),
        _PlanTemplate(
          title: 'Full Body Hypertrophy',
          timeLabel: '11:00',
          focus: 'full body',
          subtitle:
              'Moderate-intensity volume session with balanced muscle focus.',
        ),
      ];
    }

    final mobilityNote = activityLevel == 'Low'
        ? 'Balanced with easier recovery pacing to keep adherence high.'
        : 'Balanced routine that supports consistency without overload.';

    return [
      _PlanTemplate(
        title: 'Full Body Strength',
        timeLabel: '18:00',
        focus: 'full body',
        subtitle: 'Compound movement session to maintain strength and energy.',
      ),
      _PlanTemplate(
        title: 'Mobility + Cardio',
        timeLabel: '08:00',
        focus: 'mobility',
        subtitle: 'Light movement, cardio, and flexibility for recovery.',
      ),
      _PlanTemplate(
        title: 'Core Stability',
        timeLabel: '19:00',
        focus: 'core',
        subtitle: 'Core endurance and posture work for general fitness.',
      ),
      _PlanTemplate(
        title: 'Lower Body Focus',
        timeLabel: '17:30',
        focus: 'legs',
        subtitle: mobilityNote,
      ),
    ];
  }
}

class _PlanTemplate {
  final String title;
  final String timeLabel;
  final String subtitle;
  final String focus;

  const _PlanTemplate({
    required this.title,
    required this.timeLabel,
    required this.subtitle,
    required this.focus,
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
