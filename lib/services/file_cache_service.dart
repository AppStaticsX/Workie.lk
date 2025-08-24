import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileCacheService {
  static const String _cacheFolder = 'education_certificates';

  static Future<String> _getCacheDirectory() async {
    final Directory tempDir = await getTemporaryDirectory();
    final String cachePath = path.join(tempDir.path, _cacheFolder);

    // Create cache directory if it doesn't exist
    final Directory cacheDir = Directory(cachePath);
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cachePath;
  }

  static Future<File?> saveFileToCache(File sourceFile, String fileName) async {
    try {
      final String cacheDir = await _getCacheDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(fileName);
      final String baseName = path.basenameWithoutExtension(fileName);
      final String cachedFileName = '${baseName}_$timestamp$extension';
      final String cachedFilePath = path.join(cacheDir, cachedFileName);

      // Copy file to cache
      final File cachedFile = await sourceFile.copy(cachedFilePath);
      return cachedFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving file to cache: $e');
      }
      return null;
    }
  }

  static Future<void> deleteFileFromCache(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting cached file: $e');
      }
    }
  }

  static Future<void> clearAllCachedFiles() async {
    try {
      final String cacheDir = await _getCacheDirectory();
      final Directory dir = Directory(cacheDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
    }
  }
}