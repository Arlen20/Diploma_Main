import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/routing/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/widgets/glass_card.dart';
import 'package:flutter_application_1/core/widgets/gradient_background.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final _picker = ImagePicker();

  _MealSource? _selectedSource;
  _SelectedMealImage? _selectedImage;
  bool _isPicking = false;

  Future<void> _pickSource(_MealSource source) async {
    setState(() {
      _selectedSource = source;
      _isPicking = true;
    });

    try {
      final file = await _picker.pickImage(
        source: source.imageSource,
        maxWidth: 720,
        maxHeight: 720,
        imageQuality: 65,
        requestFullMetadata: false,
      );
      if (file == null) {
        if (!mounted) return;
        setState(() => _isPicking = false);
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImage = _SelectedMealImage(
          bytes: bytes,
          mimeType: file.mimeType ?? _mimeTypeFromPath(file.name),
        );
        _isPicking = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isPicking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $error')),
      );
    }
  }

  void _analyzeMeal() {
    final source = _selectedSource;
    final image = _selectedImage;
    if (source == null || image == null) return;

    context.push(
      AppRoutes.analyzingMeal,
      extra: <String, dynamic>{
        'sourceLabel': source.title,
        'imageBytes': image.bytes,
        'imageMimeType': image.mimeType,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSource = _selectedSource;
    final selectedImage = _selectedImage;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  splashRadius: 22,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Add a meal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedSource == null
                      ? 'Choose a source first, then analyze your meal.'
                      : selectedImage == null
                      ? 'Select an image from ${selectedSource.title}.'
                      : 'Preview your ${selectedSource.title} meal before analysis.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.62),
                  ),
                ),
                const SizedBox(height: 18),
                _PreviewCard(
                  source: selectedSource,
                  imageBytes: selectedImage?.bytes,
                  isPicking: _isPicking,
                ),
                const SizedBox(height: 16),
                _SourceTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Take photo',
                  subtitle: 'Use your camera for a fresh capture',
                  isSelected: selectedSource == _MealSource.camera,
                  onTap: () => _pickSource(_MealSource.camera),
                ),
                const SizedBox(height: 12),
                _SourceTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Upload from gallery',
                  subtitle: 'Use an existing meal photo from your device',
                  isSelected: selectedSource == _MealSource.gallery,
                  onTap: () => _pickSource(_MealSource.gallery),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedImage == null || _isPicking
                        ? null
                        : _analyzeMeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primaryBtnText,
                      disabledBackgroundColor: Colors.white.withOpacity(0.16),
                      disabledForegroundColor: Colors.white.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Analyze meal',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
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

enum _MealSource {
  camera(
    title: 'camera capture',
    previewAsset: 'assets/images/plov.jpg',
    imageSource: ImageSource.camera,
  ),
  gallery(
    title: 'gallery upload',
    previewAsset: 'assets/images/meal.jpg',
    imageSource: ImageSource.gallery,
  );

  final String title;
  final String previewAsset;
  final ImageSource imageSource;

  const _MealSource({
    required this.title,
    required this.previewAsset,
    required this.imageSource,
  });
}

class _PreviewCard extends StatelessWidget {
  final _MealSource? source;
  final Uint8List? imageBytes;
  final bool isPicking;

  const _PreviewCard({
    required this.source,
    required this.imageBytes,
    required this.isPicking,
  });

  @override
  Widget build(BuildContext context) {
    final asset = source?.previewAsset ?? 'assets/images/meal.jpg';
    final bytes = imageBytes;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                bytes == null
                    ? Image.asset(
                        asset,
                        height: 210,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.memory(
                        bytes,
                        height: 210,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                if (isPicking)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x66000000),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
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
            source == null
                ? 'No source selected'
                : bytes == null
                ? 'Waiting for image'
                : source!.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            source == null
                ? 'Pick camera or gallery to prepare the meal analysis.'
                : bytes == null
                ? 'Choose an image to prepare the meal analysis.'
                : 'The app will estimate calories and macros from this meal photo.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
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

class _SelectedMealImage {
  final Uint8List bytes;
  final String mimeType;

  const _SelectedMealImage({
    required this.bytes,
    required this.mimeType,
  });
}

String _mimeTypeFromPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
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
      color: Colors.white.withOpacity(isSelected ? 0.12 : 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.accent
                  : Colors.white.withOpacity(0.14),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.60),
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
                  color: isSelected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.30),
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.primaryBtnText,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
