import 'package:flutter/material.dart';

/// Stub for web: File-based images are not supported.
/// Falls back to a placeholder asset.
ImageProvider createFileImageProvider(String path) {
  // On web, local file paths are not accessible.
  // Return a placeholder — the caller should guard with kIsWeb anyway.
  return const AssetImage('assets/icon/app_icon.png');
}
