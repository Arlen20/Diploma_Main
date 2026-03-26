import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  _MealSource? _selectedSource;

  void _selectSource(_MealSource source) {
    setState(() => _selectedSource = source);
  }

  void _analyzeMeal() {
    final source = _selectedSource;
    if (source == null) return;

    context.push(
      AppRoutes.analyzingMeal,
      extra: <String, dynamic>{
        'sourceLabel': source.title,
        'previewAsset': source.previewAsset,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSource = _selectedSource;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F2FF), Color(0xFFD8C7FF), Color(0xFFBFA6FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF1C1C27),
                  ),
                  splashRadius: 22,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Add a meal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1C1C27),
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedSource == null
                      ? 'Choose a source first, then analyze your meal.'
                      : 'Preview your ${selectedSource.title} meal before analysis.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C27).withOpacity(0.60),
                  ),
                ),
                const SizedBox(height: 18),
                _PreviewCard(source: selectedSource),
                const SizedBox(height: 16),
                _SourceTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Take photo',
                  subtitle: 'Use your camera for a fresh capture',
                  isSelected: selectedSource == _MealSource.camera,
                  onTap: () => _selectSource(_MealSource.camera),
                ),
                const SizedBox(height: 12),
                _SourceTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Upload from gallery',
                  subtitle: 'Use an existing meal photo from your device',
                  isSelected: selectedSource == _MealSource.gallery,
                  onTap: () => _selectSource(_MealSource.gallery),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 28,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: selectedSource == null ? null : _analyzeMeal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B1736),
                            disabledBackgroundColor: const Color(
                              0xFF1B1736,
                            ).withOpacity(0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Analyze meal',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => context.go(AppRoutes.home),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.65),
                            side: BorderSide(
                              color: Colors.black.withOpacity(0.12),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1C1C27),
                            ),
                          ),
                        ),
                      ),
                    ],
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

enum _MealSource {
  camera(
    title: 'camera capture',
    previewAsset: 'assets/images/plov.jpg',
  ),
  gallery(
    title: 'gallery upload',
    previewAsset: 'assets/images/meal.jpg',
  );

  final String title;
  final String previewAsset;

  const _MealSource({
    required this.title,
    required this.previewAsset,
  });
}

class _PreviewCard extends StatelessWidget {
  final _MealSource? source;

  const _PreviewCard({required this.source});

  @override
  Widget build(BuildContext context) {
    final asset = source?.previewAsset ?? 'assets/images/meal.jpg';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.40),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.asset(
                  asset,
                  height: 210,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      source == null ? 'Preview' : 'Ready to analyze',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            source == null ? 'No source selected' : source!.title,
            style: const TextStyle(
              color: Color(0xFF1C1C27),
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            source == null
                ? 'Pick camera or gallery to prepare the meal analysis.'
                : 'The app will estimate calories and macros from this meal photo.',
            style: TextStyle(
              color: const Color(0xFF1C1C27).withOpacity(0.62),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1B1736)
                  : Colors.black.withOpacity(0.08),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C27).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF1C1C27)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1C1C27),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C27).withOpacity(0.60),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1B1736)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFF1C1C27).withOpacity(0.24),
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
