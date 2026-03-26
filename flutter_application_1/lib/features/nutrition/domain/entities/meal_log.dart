import 'meal_result.dart';

class MealLog {
  final String id;
  final DateTime createdAt;
  final MealResult result;

  const MealLog({
    required this.id,
    required this.createdAt,
    required this.result,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'result': result.toJson(),
      };

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['id'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      result: MealResult.fromJson(json['result'] as Map<String, dynamic>),
    );
  }
}
