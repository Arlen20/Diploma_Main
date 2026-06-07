import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/firebase_auth_providers.dart';
import '../../../profile_settings/domain/entities/user_profile.dart';
import '../../data/repositories/workout_plan_repository.dart';
import '../../domain/entities/workout_plan_entry.dart';

final workoutPlanRepositoryProvider = Provider<WorkoutPlanRepository>(
  (ref) => WorkoutPlanRepository(),
);

class WorkoutPlanNotifier extends StateNotifier<AsyncValue<List<WorkoutPlanEntry>>> {
  WorkoutPlanNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final WorkoutPlanRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.load);
  }

  Future<void> generate(UserProfile profile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.generate(profile));
  }

  Future<void> toggleCompleted(WorkoutPlanEntry entry) async {
    final current = state.valueOrNull ?? const <WorkoutPlanEntry>[];
    final updated = entry.copyWith(completed: !entry.completed);
    state = AsyncValue.data(
      current
          .map((item) => item.id == entry.id ? updated : item)
          .toList(growable: false),
    );
    try {
      await _repository.toggleCompleted(entry.id, updated.completed);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final workoutPlanProvider = StateNotifierProvider<
  WorkoutPlanNotifier,
  AsyncValue<List<WorkoutPlanEntry>>
>((ref) {
  ref.watch(authStateProvider);
  return WorkoutPlanNotifier(ref.watch(workoutPlanRepositoryProvider));
});
