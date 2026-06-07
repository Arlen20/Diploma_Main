class MealResult {
  final String title;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const MealResult({
    required this.title,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory MealResult.fromJson(Map<String, dynamic> json) {
    return MealResult(
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Estimated meal',
      calories: _toInt(json['calories']),
      protein: _toInt(json['protein']),
      carbs: _toInt(json['carbs']),
      fat: _toInt(json['fat']),
    );
  }
}

int _toInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return num.tryParse(value)?.round() ?? 0;
  return 0;
}
