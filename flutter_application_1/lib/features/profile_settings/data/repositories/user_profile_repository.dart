import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_profile.dart';

class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<UserProfile> load() async {
    final user = _auth.currentUser;
    if (user == null) {
      return UserProfile.empty;
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();

    if (!snapshot.exists) {
      final fallbackProfile = UserProfile.empty.copyWith(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? UserProfile.empty.name,
      );
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(fallbackProfile.toJson(), SetOptions(merge: true));
      return fallbackProfile;
    }

    final data = snapshot.data() ?? <String, dynamic>{};
    return UserProfile.fromJson(data).copyWith(
      uid: user.uid,
      email: user.email ?? data['email'] as String? ?? '',
    );
  }

  Future<void> save(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(
          profile
              .copyWith(uid: user.uid, email: user.email ?? profile.email)
              .toJson(),
          SetOptions(merge: true),
        );
  }

  Future<void> clear() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).delete();
  }
}
