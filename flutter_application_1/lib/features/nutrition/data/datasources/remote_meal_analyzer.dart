import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../domain/entities/meal_result.dart';
import 'meal_analyzer.dart';

class RemoteMealAnalyzer implements MealAnalyzer {
  final List<Uri> endpoints;
  final http.Client _client;

  RemoteMealAnalyzer({
    Uri? endpoint,
    List<Uri>? endpoints,
    http.Client? client,
  }) : endpoints = endpoints ?? [if (endpoint != null) endpoint],
       _client = client ?? http.Client() {
    if (this.endpoints.isEmpty) {
      throw ArgumentError('At least one meal analyzer endpoint is required.');
    }
  }

  @override
  Future<MealResult> analyze({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    Object? lastError;

    for (final endpoint in endpoints) {
      try {
        return await _analyzeWithEndpoint(
          endpoint: endpoint,
          imageBytes: imageBytes,
          mimeType: mimeType,
        );
      } catch (error) {
        lastError = error;
      }
    }

    throw MealAnalyzerException(
      'Meal analyzer backend is not available. Start the functions emulator '
      'or deploy Firebase Functions. Last error: $lastError',
    );
  }

  Future<MealResult> _analyzeWithEndpoint({
    required Uri endpoint,
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    final response = await _client
        .post(
          endpoint,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'imageBase64': base64Encode(imageBytes),
            'mimeType': mimeType,
          }),
        )
        .timeout(
          const Duration(seconds: 45),
          onTimeout: () {
            throw const MealAnalyzerException('Meal analysis timed out.');
          },
        );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMessage = _errorMessageFromBody(response.body);
      throw MealAnalyzerException(
        errorMessage ??
            'Meal analysis failed at $endpoint with status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const MealAnalyzerException('Meal analysis returned invalid data.');
    }

    return MealResult.fromJson(Map<String, dynamic>.from(decoded));
  }
}

String? _errorMessageFromBody(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map && decoded['error'] is String) {
      return decoded['error'] as String;
    }
  } catch (_) {
    return null;
  }

  return null;
}

class MealAnalyzerException implements Exception {
  final String message;

  const MealAnalyzerException(this.message);

  @override
  String toString() => message;
}

class MissingMealAnalyzer implements MealAnalyzer {
  @override
  Future<MealResult> analyze({
    required Uint8List imageBytes,
    required String mimeType,
  }) {
    throw const MealAnalyzerException(
      'Meal analyzer backend URL is not configured.',
    );
  }
}
