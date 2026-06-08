/// Pure health/nutrition math derived from the user's profile and meal logs.
///
/// Calorie target uses the Mifflin-St Jeor BMR, scaled by an activity factor
/// and adjusted for the user's goal. Macros use a 30/40/30 (P/C/F) split.
class DailyTargets {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const DailyTargets({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class HealthCalculator {
  static double _bmr({
    required String sex,
    required int heightCm,
    required int weightKg,
    required int age,
  }) {
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    switch (sex.toLowerCase()) {
      case 'male':
        return base + 5;
      case 'female':
        return base - 161;
      default:
        return base - 78; // average of the male/female constants
    }
  }

  static double _activityFactor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return 1.3;
      case 'high':
        return 1.75;
      case 'moderate':
      default:
        return 1.55;
    }
  }

  static int _goalAdjustment(String goal) {
    final g = goal.toLowerCase();
    if (g.contains('lose')) return -500;
    if (g.contains('gain')) return 300;
    return 0;
  }

  static DailyTargets dailyTargets({
    required String sex,
    required int heightCm,
    required int weightKg,
    required int age,
    required String activityLevel,
    required String goal,
  }) {
    final tdee = _bmr(
          sex: sex,
          heightCm: heightCm,
          weightKg: weightKg,
          age: age,
        ) *
        _activityFactor(activityLevel);

    var calories = (tdee + _goalAdjustment(goal)).round();
    if (calories < 1200) calories = 1200;

    final protein = (calories * 0.30 / 4).round();
    final carbs = (calories * 0.40 / 4).round();
    final fat = (calories * 0.30 / 9).round();

    return DailyTargets(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }

  static double bmi({required int heightCm, required int weightKg}) {
    if (heightCm <= 0) return 0;
    final meters = heightCm / 100.0;
    return weightKg / (meters * meters);
  }

  static String bmiCategory(double bmi) {
    if (bmi <= 0) return '-';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// Consecutive days (ending today, with a one-day grace) that have at least
  /// one logged meal.
  static int currentStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final days = dates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);

    // Allow the streak to stand if today isn't logged yet but yesterday was.
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }

    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
