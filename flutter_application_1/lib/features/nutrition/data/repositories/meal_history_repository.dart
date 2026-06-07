import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/meal_log.dart';
import '../../domain/entities/meal_result.dart';

class MealHistoryRepository {
  MealHistoryRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _mealCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('meals');
  }

  Future<List<MealLog>> load() async {
    final user = _auth.currentUser;
    if (user == null) return const [];

    final snapshot = await _mealCollection(
      user.uid,
    ).orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final createdAtRaw = data['createdAt'];
      final createdAt = createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse(createdAtRaw as String? ?? '') ?? DateTime.now();

      return MealLog(
        id: doc.id,
        createdAt: createdAt,
        result: MealResult.fromJson(
          Map<String, dynamic>.from(data['result'] as Map? ?? {}),
        ),
        imageBase64: data['imageBase64'] as String? ?? '',
        imageMimeType: data['imageMimeType'] as String? ?? 'image/jpeg',
      );
    }).toList(growable: false);
  }

  Future<MealLog> add(
    MealResult result, {
    Uint8List? imageBytes,
    String imageMimeType = 'image/jpeg',
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to save meals.');
    }

    final createdAt = DateTime.now();
    final doc = _mealCollection(user.uid).doc();
    final imageBase64 = imageBytes == null ? '' : base64Encode(imageBytes);
    final log = MealLog(
      id: doc.id,
      createdAt: createdAt,
      result: result,
      imageBase64: imageBase64,
      imageMimeType: imageMimeType,
    );

    await doc.set({
      'createdAt': Timestamp.fromDate(createdAt),
      'result': result.toJson(),
      'imageBase64': imageBase64,
      'imageMimeType': imageMimeType,
    });

    return log;
  }

  Future<void> remove(String id) async {
    final user = _auth.currentUser;
    if (user == null || id.isEmpty) return;
    await _mealCollection(user.uid).doc(id).delete();
  }

  Future<void> clear() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _mealCollection(user.uid).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
