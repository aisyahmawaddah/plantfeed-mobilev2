import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  final customCacheManager = CacheManager(
    Config(
      'cacheKey',
      stalePeriod: const Duration(
        days: 15,
      ),
      maxNrOfCacheObjects: 240,
    ),
  );
}
