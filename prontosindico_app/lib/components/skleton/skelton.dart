import 'package:flutter/material.dart';

import '../../constants.dart';

import 'package:shimmer/shimmer.dart';

class Skeleton extends StatelessWidget {
  const Skeleton(
      {super.key,
      this.height,
      this.width,
      this.layer = 1,
      this.radious = defaultPadding});

  final double? height, width;
  final int layer;
  final double radious;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(radious))),
      ),
    );
  }
}

class CircleSkeleton extends StatelessWidget {
  const CircleSkeleton({super.key, this.size = 24});

  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      // padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        // color: Theme.of(context).primaryColor.withOpacity(0.04),
        color: Theme.of(context).iconTheme.color!.withOpacity(0.04),
        shape: BoxShape.circle,
      ),
    );
  }
}
