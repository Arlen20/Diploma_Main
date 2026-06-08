import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'core/storage/app_paths.dart';
import 'core/theme/app_colors.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Keep the system bars dark so there is never a white strip behind the
  // gradient (the default light theme paints the Android nav bar white).
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgBottom,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final documentsDir = await getApplicationDocumentsDirectory();

  runApp(
    ProviderScope(
      overrides: [
        appDocumentsPathProvider.overrideWithValue(documentsDir.path),
      ],
      child: const App(),
    ),
  );
}
