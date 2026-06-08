import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/firebase_auth_providers.dart';
import '../../data/repositories/water_repository.dart';

final waterRepositoryProvider = Provider<WaterRepository>(
  (ref) => WaterRepository(),
);

/// Daily water goal in glasses.
const int kWaterDailyGoal = 8;

class WaterNotifier extends StateNotifier<AsyncValue<int>> {
  WaterNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final WaterRepository _repository;

  Future<void> load() async {
    state = await AsyncValue.guard(_repository.loadToday);
  }

  Future<void> add() async {
    final next = ((state.valueOrNull ?? 0) + 1).clamp(0, 30);
    state = AsyncValue.data(next);
    await _repository.saveToday(next);
  }

  Future<void> remove() async {
    final next = ((state.valueOrNull ?? 0) - 1).clamp(0, 30);
    state = AsyncValue.data(next);
    await _repository.saveToday(next);
  }
}

final waterProvider =
    StateNotifierProvider<WaterNotifier, AsyncValue<int>>((ref) {
      ref.watch(authStateProvider);
      return WaterNotifier(ref.watch(waterRepositoryProvider));
    });
