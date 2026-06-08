import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';

import '../../data/datasources/remote_meal_analyzer.dart';
import '../../domain/entities/meal_result.dart';

class AnalyzingMealPage extends StatefulWidget {
  const AnalyzingMealPage({super.key});

  @override
  State<AnalyzingMealPage> createState() => _AnalyzingMealPageState();
}

class _AnalyzingMealPageState extends State<AnalyzingMealPage> {
  static const _remoteEndpoint =
      'https://analyzemeal-uob437bgka-uc.a.run.app';
  static const _localEndpoint =
      'http://127.0.0.1:5001/diploma-fitness-app/us-central1/analyzeMeal';
  static const _endpointOverride = String.fromEnvironment(
    'MEAL_ANALYZER_URL',
    defaultValue: '',
  );

  late final _analyzer = RemoteMealAnalyzer(endpoints: _analyzerEndpoints());
  final _progressMessages = const [
    'Reading the meal photo',
    'Estimating portion size',
    'Calculating calories and macros',
  ];

  Timer? _stageTimer;
  int _stageIndex = 0;
  bool _canceled = false;
  bool _started = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _run();
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    _stageTimer = Timer.periodic(const Duration(milliseconds: 850), (timer) {
      if (!mounted) return;
      if (_stageIndex >= _progressMessages.length - 1) {
        timer.cancel();
        return;
      }
      setState(() => _stageIndex += 1);
    });
  }

  Future<void> _run() async {
    final payload = _payload(context);
    final imageBytes = payload['imageBytes'];
    final imageMimeType = payload['imageMimeType'] as String? ?? 'image/jpeg';

    if (imageBytes is! Uint8List) {
      _showError('Meal image is missing. Please choose a photo again.');
      return;
    }

    try {
      final MealResult result = await _analyzer.analyze(
        imageBytes: imageBytes,
        mimeType: imageMimeType,
      );
      if (!mounted || _canceled) return;

      _stageTimer?.cancel();
      context.go(
        AppRoutes.mealResult,
        extra: <String, dynamic>{
          'result': result,
          'imageBytes': imageBytes,
          'imageMimeType': imageMimeType,
        },
      );
    } catch (error) {
      _showError(error.toString());
    }
  }

  List<Uri> _analyzerEndpoints() {
    if (_endpointOverride.isNotEmpty) {
      return [Uri.parse(_endpointOverride)];
    }

    final host = Uri.base.host;
    final isLocalFlutterWeb =
        host == 'localhost' || host == '127.0.0.1' || host == '::1';

    if (isLocalFlutterWeb) {
      return [Uri.parse(_localEndpoint)];
    }

    return [Uri.parse(_remoteEndpoint)];
  }

  void _showError(String message) {
    if (!mounted || _canceled) return;
    _stageTimer?.cancel();
    setState(() => _errorMessage = message);
  }

  void _retry() {
    setState(() {
      _errorMessage = null;
      _stageIndex = 0;
    });
    _startProgress();
    _run();
  }

  @override
  Widget build(BuildContext context) {
    final payload = _payload(context);
    final sourceLabel = (payload['sourceLabel'] as String?) ?? 'meal photo';
    final imageBytes = payload['imageBytes'];
    final errorMessage = _errorMessage;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B2352), Color(0xFF1B1736)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    _canceled = true;
                    context.pop();
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                  splashRadius: 22,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Analyzing\nyour meal',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Using your $sourceLabel to estimate calories, protein, carbs, and fat.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.62),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.14)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: imageBytes is Uint8List
                        ? Image.memory(
                            imageBytes,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/meal.jpg',
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (errorMessage == null)
                          Row(
                            children: [
                              SizedBox(
                                width: 58,
                                height: 58,
                                child: CircularProgressIndicator(
                                  value: (_stageIndex + 1) /
                                      _progressMessages.length,
                                  strokeWidth: 7,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.18,
                                  ),
                                  valueColor: const AlwaysStoppedAnimation(
                                    Color(0xFFF3F0B6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'AI analysis in progress',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _progressMessages[_stageIndex],
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.60),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          _ErrorPanel(message: errorMessage),
                        const SizedBox(height: 20),
                        if (errorMessage == null)
                          ...List.generate(_progressMessages.length, (index) {
                            final isDone = index < _stageIndex;
                            final isActive = index == _stageIndex;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _StageRow(
                                text: _progressMessages[index],
                                isDone: isDone,
                                isActive: isActive,
                              ),
                            );
                          }),
                        const Spacer(),
                        if (errorMessage == null)
                          Text(
                            'Please wait a few seconds. You will be redirected automatically when the analysis is ready.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.56),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          )
                        else
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF3F0B6),
                                    foregroundColor: const Color(0xFF1B1736),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  onPressed: _retry,
                                  child: const Text(
                                    'Try again',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: () => context.go(AppRoutes.addMeal),
                                  child: const Text(
                                    'Choose another photo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Map<String, dynamic> _payload(BuildContext context) {
  final extra = GoRouterState.of(context).extra;
  return extra is Map<String, dynamic>
      ? Map<String, dynamic>.from(extra)
      : const <String, dynamic>{};
}

class _ErrorPanel extends StatelessWidget {
  final String message;

  const _ErrorPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFCDEB),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFF1C1C27),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analysis failed',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StageRow extends StatelessWidget {
  final String text;
  final bool isDone;
  final bool isActive;

  const _StageRow({
    required this.text,
    required this.isDone,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDone
        ? const Color(0xFFF3F0B6)
        : isActive
        ? Colors.white.withOpacity(0.20)
        : Colors.white.withOpacity(0.10);
    final iconColor = isDone
        ? const Color(0xFF1B1736)
        : Colors.white;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            isDone
                ? Icons.check_rounded
                : isActive
                ? Icons.bolt_rounded
                : Icons.more_horiz_rounded,
            size: 16,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(
                isDone || isActive ? 0.92 : 0.56,
              ),
              fontWeight: isDone || isActive ? FontWeight.w800 : FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
