import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Absolute path to the app's documents directory.
///
/// Resolved once at startup and injected via an override in `main()`. We store
/// only the avatar *filename* in the profile and rebuild the absolute path from
/// this at display time, because the absolute container path can change between
/// app launches/reinstalls (so a stored absolute path would break).
final appDocumentsPathProvider = Provider<String>(
  (ref) => throw UnimplementedError('appDocumentsPathProvider not initialized'),
);

/// Rebuilds the absolute path to a locally stored avatar.
///
/// Accepts both the new format (a bare filename) and the legacy format (a full
/// absolute path saved by older builds), so existing profiles keep working.
String resolveLocalAvatarPath(String docsPath, String stored) {
  if (stored.isEmpty) return '';
  if (stored.startsWith('/')) return stored; // legacy absolute path
  return '$docsPath/$stored';
}
