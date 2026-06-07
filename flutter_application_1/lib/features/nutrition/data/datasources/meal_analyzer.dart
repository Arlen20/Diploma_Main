import 'dart:typed_data';

import '../../domain/entities/meal_result.dart';

abstract class MealAnalyzer {
  Future<MealResult> analyze({
    required Uint8List imageBytes,
    required String mimeType,
  });
}
