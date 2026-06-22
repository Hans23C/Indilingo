import 'package:flutter/material.dart';

class AppAssetImage extends StatelessWidget {
  final String asset;
  final IconData fallbackIcon;
  final Color color;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppAssetImage({
    super.key,
    required this.asset,
    required this.fallbackIcon,
    required this.color,
    this.size = 42,
    this.fit = BoxFit.contain,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final child = asset.isEmpty
        ? _fallbackIcon()
        : Image.asset(
            asset,
            fit: fit,
            errorBuilder: (_, __, ___) => _fallbackIcon(),
          );

    return SizedBox(
      width: size,
      height: size,
      child: borderRadius == null
          ? child
          : ClipRRect(borderRadius: borderRadius!, child: child),
    );
  }

  Widget _fallbackIcon() {
    return Icon(fallbackIcon, color: color, size: size * 0.72);
  }
}
