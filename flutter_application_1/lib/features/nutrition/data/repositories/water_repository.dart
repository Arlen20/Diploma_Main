import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Stores the number of water glasses logged per day under
/// users/{uid}/water/{yyyy-mm-dd}.
class WaterRepository {
  WaterRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static String _todayKey() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  DocumentReference<Map<String, dynamic>>? _todayDoc() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('water')
        .doc(_todayKey());
  }

  Future<int> loadToday() async {
    final doc = _todayDoc();
    if (doc == null) return 0;
    final snapshot = await doc.get();
    return (snapshot.data()?['count'] as int?) ?? 0;
  }

  Future<void> saveToday(int count) async {
    final doc = _todayDoc();
    if (doc == null) return;
    await doc.set(
      {'count': count, 'date': _todayKey()},
      SetOptions(merge: true),
    );
  }
}
