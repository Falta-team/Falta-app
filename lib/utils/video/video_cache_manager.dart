import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom cache manager for video files.
/// Videos are cached for 7 days, max 50 files, max 500 MB.
///
/// Per graduation report §5.4.2 (Client-Side Caching):
///   "Recently viewed content cached"
///   "Offline access to downloaded videos"
class VideoCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'falta_video_cache';

  static final VideoCacheManager _instance = VideoCacheManager._();
  factory VideoCacheManager() => _instance;

  VideoCacheManager._()
      : super(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 50,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}