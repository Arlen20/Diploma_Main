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
      title: json['title'] as String,
      calories: json['calories'] as int,
      protein: json['protein'] as int,
      carbs: json['carbs'] as int,
      fat: json['fat'] as int,
    );
  }
}
