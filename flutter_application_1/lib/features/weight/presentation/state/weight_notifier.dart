import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/firebase_auth_providers.dart';
import '../../data/repositories/weight_repository.dart';
import '../../domain/entities/weight_entry.dart';

final weightRepositoryProvider = Provider<WeightRepository>(
  (ref) => WeightRepository(),
);

class WeightNotifier extends StateNotifier<AsyncValue<List<WeightEntry>>> {
  WeightNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final WeightRepository _repository;

  Future<void> load() async {
    state = await AsyncValue.guard(_repository.load);
  }

  Future<void> add(double weightKg) async {
    final entry = await _repository.add(weightKg);
    final current = state.valueOrNull ?? const <WeightEntry>[];
    state = AsyncValue.data([...current, entry]);
  }
}

final weightProvider =
    StateNotifierProvider<WeightNotifier, AsyncValue<List<WeightEntry>>>((ref) {
      ref.watch(authStateProvider);
      return WeightNotifier(ref.watch(weightRepositoryProvider));
    });
