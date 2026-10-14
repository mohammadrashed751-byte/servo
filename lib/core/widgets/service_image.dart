import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

class ServiceImage extends StatelessWidget {
  const ServiceImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.isAvatar = false,
  });
  final String path;
  final bool isAvatar;
  Widget get _fallback => isAvatar
      ? SizedBox(
          width: width,
          height: height,
          child: const Icon(Icons.person_outline),
        )
      : Image.asset(
          AppAssets.authHeader4,
          width: width,
          height: height,
          fit: fit,
        );
  final double? width;
  final double? height;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(path);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _fallback,
      );
    }
    if (path.isEmpty) return _fallback;
    return Image.asset(path, width: width, height: height, fit: fit);
  }
}
