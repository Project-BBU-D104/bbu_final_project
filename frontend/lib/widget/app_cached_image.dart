import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppCachedImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final IconData? errorIcon;
  final double fallbackIconSize;

  const AppCachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_not_supported_outlined,
    this.errorIcon,
    this.fallbackIconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _fallback(fallbackIcon);
    }
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
        child: Icon(icon, color: Colors.grey[400], size: fallbackIconSize),
      );
}
