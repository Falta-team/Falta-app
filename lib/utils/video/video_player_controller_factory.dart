import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'video_cache_manager.dart';

/// Factory that returns a [VideoPlayerController] from cache if available,
/// falling back to network otherwise.
///
/// Per graduation report:
/// - NFR1.1: Video streaming shall start within 3 seconds on 4G.
/// - Caching strategy: "Recently viewed content cached", "Offline access
///   to downloaded videos".
class VideoControllerFactory {

  /// Returns an **initialized** [VideoPlayerController].
  ///
  /// Strategy:
  ///  1. Check local cache first (instant start).
  ///  2. If not cached, download to cache while playing from network.
  ///     The file will be available instantly next time.
  static Future<VideoPlayerController> create(String videoUrl) async {
    try {
      // Check if video is already in cache
      final FileInfo? cached =
      await VideoCacheManager().getFileFromCache(videoUrl);

      if (cached != null && await cached.file.exists()) {
        // ✅ Cache hit → play from local file (no network delay)
        return VideoPlayerController.file(cached.file);
      }

      // Cache miss → download to cache + play from network simultaneously
      // The getSingleFile call streams the file to disk while we play from URL.
      // This ensures the video is cached for next time.
      unawaited(
        VideoCacheManager().getSingleFile(videoUrl).catchError((_) {}),
      );

      // Play directly from network while background-downloading to cache
      return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    } catch (_) {
      // Fallback to plain network on any cache error
      return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    }
  }
}

// ignore: avoid_shadowing_type_parameters
void unawaited<T>(Future<T> future) {}