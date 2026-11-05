import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppCachedImage extends StatelessWidget {
  final String? url;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final IconData? errorIcon;
  final double fallbackIconSize;

  const AppCachedImage({
    super.key,
    this.url,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_not_supported_outlined,
    this.errorIcon,
    this.fallbackIconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    // Local asset image
    if (assetPath != null && assetPath!.isNotEmpty) {
      return Image.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _fallback(errorIcon ?? fallbackIcon),
      );
    }

    // Empty URL
    if (url == null || url!.isEmpty) {
      return _fallback(fallbackIcon);
    }

    // Network cached image
    return CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width != null && width!.isFinite
          ? (width! * 3).round()
          : null,
      placeholder: (_, _) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF5F5F5),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, _, _) => _fallback(errorIcon ?? fallbackIcon),
    );
  }

  Widget _fallback(IconData icon) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF5F5F5),
        child: Icon(
          icon,
          color: Colors.grey[400],
          size: fallbackIconSize,
        ),
      );
}