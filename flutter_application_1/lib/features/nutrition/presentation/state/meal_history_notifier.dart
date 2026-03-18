import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/meal_log.dart';

class MealHistoryNotifier extends StateNotifier<List<MealLog>> {
  static const _storageKey = 'meal_history';

  MealHistoryNotifier() : super(const []) {
    _load();
  }

  void add(MealLog log) {
    state = [log, ...state]; // newest first
    _save();
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.length) return;
    state = [...state]..removeAt(index);
    _save();
  }

  void clear() {
    state = const [];
    _save();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw) as List<dynamic>;
      state = decoded
          .map((e) => MealLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // If parsing fails, keep empty state.
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload =
          jsonEncode(state.map((e) => e.toJson()).toList(growable: false));
      await prefs.setString(_storageKey, payload);
    } catch (_) {
      // Best-effort persistence.
    }
  }
}

final mealHistoryProvider =
    StateNotifierProvider<MealHistoryNotifier, List<MealLog>>(
      (ref) => MealHistoryNotifier(),
    );
