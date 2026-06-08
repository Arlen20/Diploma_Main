import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/weight_entry.dart';

/// Stores weight measurements under users/{uid}/weights.
class WeightRepository {
  WeightRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>? _collection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('weights');
  }

  Future<List<WeightEntry>> load() async {
    final col = _collection();
    if (col == null) return const [];

    final snapshot = await col.orderBy('date').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final raw = data['date'];
      final date = raw is Timestamp
          ? raw.toDate()
          : DateTime.tryParse(raw as String? ?? '') ?? DateTime.now();
      return WeightEntry(
        id: doc.id,
        date: date,
        weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0,
      );
    }).toList(growable: false);
  }

  Future<WeightEntry> add(double weightKg) async {
    final col = _collection();
    if (col == null) {
      throw StateError('User must be signed in to log weight.');
    }

    final date = DateTime.now();
    final doc = col.doc();
    await doc.set({
      'date': Timestamp.fromDate(date),
      'weightKg': weightKg,
    });
    return WeightEntry(id: doc.id, date: date, weightKg: weightKg);
  }
}
