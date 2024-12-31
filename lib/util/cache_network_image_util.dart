import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget placeholder;
  final Widget errorWidget;
  final CacheManager? cacheManager;

  const CustomCachedNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.cacheManager,
    this.fit = BoxFit.cover,
    this.placeholder = const CircularProgressIndicator(),
    this.errorWidget = const Icon(Icons.error),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      key: UniqueKey(),
      width: width,
      height: height,
      fit: fit,
      cacheManager: cacheManager,
      imageUrl: imageUrl,
      placeholder: (BuildContext context, String url) {
        return Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: placeholder,
          ),
        );
      },
      errorWidget: (BuildContext context, String url, dynamic error) {
        return errorWidget;
      },
    );
  }
}
