import '../../domain/entities/meal_result.dart';

class MockMealAnalyzer {
  Future<MealResult> analyze() async {
    // simulate AI processing time
    await Future.delayed(const Duration(seconds: 2));

    // return fake nutrition result
    return const MealResult(
      title: 'Chicken + Rice + Veggies',
      calories: 540,
      protein: 28,
      carbs: 62,
      fat: 18,
    );
  }
}
