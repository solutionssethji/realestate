import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageUtils {
  /// Compresses an image from file path with high quality.
  /// 1280px max dimension, quality 80 (~150KB - 250KB).
  static Future<Uint8List> compressImage(
    String filePath, {
    int minWidth = 1280,
    int minHeight = 1280,
    int quality = 80,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      final compressed = await FlutterImageCompress.compressWithFile(
        filePath,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressed != null && compressed.isNotEmpty) {
        return compressed;
      }
    } catch (e) {
      debugPrint('compressWithFile failed, attempting compressWithList fallback: $e');
    }

    try {
      final bytes = await File(filePath).readAsBytes();
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      if (compressed.isNotEmpty) {
        return compressed;
      }
    } catch (e) {
      debugPrint('compressWithList fallback failed: $e');
    }

    return await File(filePath).readAsBytes();
  }

  /// High-resolution profile photo compression (512x512, quality 75).
  /// Ultra-fast upload (<1 sec, ~40-60KB) and crisp on avatars.
  static Future<Uint8List> compressProfileImage(String filePath) async {
    return compressImage(filePath, minWidth: 512, minHeight: 512, quality: 75);
  }

  /// Pre-cache image bytes directly into DefaultCacheManager disk cache.
  /// This ensures CachedNetworkImage finds the image immediately in 0ms without flicker!
  static Future<void> preCacheImageBytes(String url, Uint8List bytes) async {
    try {
      await DefaultCacheManager().putFile(
        url,
        bytes,
        key: url,
        fileExtension: 'jpg',
      );
    } catch (e) {
      debugPrint('ImageUtils.preCacheImageBytes error: $e');
    }
  }

  /// Evict an image URL from both CachedNetworkImage and DefaultCacheManager
  static Future<void> evictImage(String url) async {
    try {
      await CachedNetworkImage.evictFromCache(url);
      await DefaultCacheManager().removeFile(url);
    } catch (e) {
      debugPrint('ImageUtils.evictImage error: $e');
    }
  }
}
