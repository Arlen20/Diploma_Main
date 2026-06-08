import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/firebase_auth_providers.dart';
import '../../data/repositories/meal_history_repository.dart';
import '../../domain/entities/meal_log.dart';
import '../../domain/entities/meal_result.dart';

final mealHistoryRepositoryProvider = Provider<MealHistoryRepository>(
  (ref) => MealHistoryRepository(),
);

class MealHistoryNotifier extends StateNotifier<AsyncValue<List<MealLog>>> {
  MealHistoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final MealHistoryRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.load);
  }

  Future<MealLog> add(
    MealResult result, {
    Uint8List? imageBytes,
    String imageMimeType = 'image/jpeg',
    String category = '',
  }) async {
    final current = state.valueOrNull ?? const <MealLog>[];
    final log = await _repository.add(
      result,
      imageBytes: imageBytes,
      imageMimeType: imageMimeType,
      category: category,
    );
    state = AsyncValue.data([log, ...current]);
    return log;
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? const <MealLog>[];
    state = AsyncValue.data(current.where((item) => item.id != id).toList());
    try {
      await _repository.remove(id);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clear() async {
    state = const AsyncValue.data(<MealLog>[]);
    try {
      await _repository.clear();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final mealHistoryProvider =
    StateNotifierProvider<MealHistoryNotifier, AsyncValue<List<MealLog>>>((ref) {
      ref.watch(authStateProvider);
      return MealHistoryNotifier(ref.watch(mealHistoryRepositoryProvider));
    });
