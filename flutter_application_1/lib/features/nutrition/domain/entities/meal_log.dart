import 'meal_result.dart';

/// Meal categories used to tag a logged meal.
class MealCategories {
  static const all = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  /// Picks a sensible default based on the time of day.
  static String defaultForTime(DateTime time) {
    final h = time.hour;
    if (h < 11) return 'Breakfast';
    if (h < 16) return 'Lunch';
    if (h < 21) return 'Dinner';
    return 'Snack';
  }
}

class MealLog {
  final String id;
  final DateTime createdAt;
  final MealResult result;
  final String imageBase64;
  final String imageMimeType;
  final String category;

  const MealLog({
    required this.id,
    required this.createdAt,
    required this.result,
    this.imageBase64 = '',
    this.imageMimeType = 'image/jpeg',
    this.category = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'result': result.toJson(),
        'imageBase64': imageBase64,
        'imageMimeType': imageMimeType,
        'category': category,
      };

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['id'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      result: MealResult.fromJson(
        Map<String, dynamic>.from(json['result'] as Map? ?? {}),
      ),
      imageBase64: json['imageBase64'] as String? ?? '',
      imageMimeType: json['imageMimeType'] as String? ?? 'image/jpeg',
      category: json['category'] as String? ?? '',
    );
  }
}
