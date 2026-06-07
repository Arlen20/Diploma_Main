class WorkoutPlanEntry {
  final String id;
  final int dayOfWeek;
  final String title;
  final String timeLabel;
  final String subtitle;
  final String focus;
  final bool completed;
  final String generator;
  final List<WorkoutExercise> exercises;

  const WorkoutPlanEntry({
    required this.id,
    required this.dayOfWeek,
    required this.title,
    required this.timeLabel,
    required this.subtitle,
    required this.focus,
    required this.completed,
    required this.generator,
    required this.exercises,
  });

  WorkoutPlanEntry copyWith({
    String? id,
    int? dayOfWeek,
    String? title,
    String? timeLabel,
    String? subtitle,
    String? focus,
    bool? completed,
    String? generator,
    List<WorkoutExercise>? exercises,
  }) {
    return WorkoutPlanEntry(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      title: title ?? this.title,
      timeLabel: timeLabel ?? this.timeLabel,
      subtitle: subtitle ?? this.subtitle,
      focus: focus ?? this.focus,
      completed: completed ?? this.completed,
      generator: generator ?? this.generator,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'title': title,
    'timeLabel': timeLabel,
    'subtitle': subtitle,
    'focus': focus,
    'completed': completed,
    'generator': generator,
    'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
  };

  factory WorkoutPlanEntry.fromJson(String id, Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List<dynamic>? ?? const [];
    return WorkoutPlanEntry(
      id: id,
      dayOfWeek: json['dayOfWeek'] as int? ?? 1,
      title: json['title'] as String? ?? 'Workout',
      timeLabel: json['timeLabel'] as String? ?? '18:00',
      subtitle: json['subtitle'] as String? ?? '',
      focus: json['focus'] as String? ?? 'general',
      completed: json['completed'] as bool? ?? false,
      generator: json['generator'] as String? ?? 'mock_ai_v1',
      exercises: rawExercises
          .whereType<Map<String, dynamic>>()
          .map(WorkoutExercise.fromJson)
          .toList(growable: false),
    );
  }
}

enum WorkoutExerciseMode { reps, timed }

class WorkoutExercise {
  final String name;
  final String assetPath;
  final String instruction;
  final WorkoutExerciseMode mode;
  final int sets;
  final int? reps;
  final int? durationSeconds;
  final int restSeconds;

  const WorkoutExercise({
    required this.name,
    required this.assetPath,
    required this.instruction,
    required this.mode,
    required this.sets,
    required this.reps,
    required this.durationSeconds,
    required this.restSeconds,
  });

  bool get isTimed => mode == WorkoutExerciseMode.timed;

  String get targetLabel {
    if (isTimed) {
      return '${durationSeconds ?? 30}s';
    }
    return '$sets x ${reps ?? 10} reps';
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'assetPath': assetPath,
    'instruction': instruction,
    'mode': mode.name,
    'sets': sets,
    'reps': reps,
    'durationSeconds': durationSeconds,
    'restSeconds': restSeconds,
  };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    final modeName = json['mode'] as String? ?? WorkoutExerciseMode.timed.name;
    final mode = WorkoutExerciseMode.values.firstWhere(
      (item) => item.name == modeName,
      orElse: () => WorkoutExerciseMode.timed,
    );

    return WorkoutExercise(
      name: json['name'] as String? ?? 'Exercise',
      assetPath: json['assetPath'] as String? ?? '',
      instruction: json['instruction'] as String? ?? '',
      mode: mode,
      sets: json['sets'] as int? ?? 1,
      reps: json['reps'] as int?,
      durationSeconds: json['durationSeconds'] as int?,
      restSeconds: json['restSeconds'] as int? ?? 30,
    );
  }
}
