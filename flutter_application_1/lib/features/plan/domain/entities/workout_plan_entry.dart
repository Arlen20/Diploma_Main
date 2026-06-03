class WorkoutPlanEntry {
  final String id;
  final int dayOfWeek;
  final String title;
  final String timeLabel;
  final String subtitle;
  final String focus;
  final bool completed;
  final String generator;

  const WorkoutPlanEntry({
    required this.id,
    required this.dayOfWeek,
    required this.title,
    required this.timeLabel,
    required this.subtitle,
    required this.focus,
    required this.completed,
    required this.generator,
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
      };

  factory WorkoutPlanEntry.fromJson(String id, Map<String, dynamic> json) {
    return WorkoutPlanEntry(
      id: id,
      dayOfWeek: json['dayOfWeek'] as int? ?? 1,
      title: json['title'] as String? ?? 'Workout',
      timeLabel: json['timeLabel'] as String? ?? '18:00',
      subtitle: json['subtitle'] as String? ?? '',
      focus: json['focus'] as String? ?? 'general',
      completed: json['completed'] as bool? ?? false,
      generator: json['generator'] as String? ?? 'mock_ai_v1',
    );
  }
}
