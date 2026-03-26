import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/firebase_auth_providers.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../domain/entities/user_profile.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => UserProfileRepository(),
);

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  UserProfileNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    load();
  }

  final UserProfileRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.load);
  }

  Future<void> save(UserProfile profile) async {
    final next = profile.uid.isEmpty && state.valueOrNull != null
        ? profile.copyWith(
            uid: state.valueOrNull!.uid,
            email: state.valueOrNull!.email,
          )
        : profile;
    state = AsyncValue.data(next);
    try {
      await _repository.save(next);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> reset() async {
    const profile = UserProfile.empty;
    state = const AsyncValue.data(profile);
    try {
      await _repository.clear();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>(
      (ref) {
        ref.watch(authStateProvider);
        return UserProfileNotifier(ref.watch(userProfileRepositoryProvider));
      },
    );
