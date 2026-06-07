import 'meal_result.dart';

class MealLog {
  final String id;
  final DateTime createdAt;
  final MealResult result;
  final String imageBase64;
  final String imageMimeType;

  const MealLog({
    required this.id,
    required this.createdAt,
    required this.result,
    this.imageBase64 = '',
    this.imageMimeType = 'image/jpeg',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'result': result.toJson(),
        'imageBase64': imageBase64,
        'imageMimeType': imageMimeType,
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
    );
  }
}
