import 'dart:io';
import 'package:flutter/material.dart';

/// Returns a FileImage for the given path on native platforms.
ImageProvider createFileImageProvider(String path) {
  return FileImage(File(path));
}
