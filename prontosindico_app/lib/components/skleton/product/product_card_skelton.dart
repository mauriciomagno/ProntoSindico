import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../skelton.dart';

class ProductCardSkelton extends StatelessWidget {
  const ProductCardSkelton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 154,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious * 1.5),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: Skeleton(radious: defaultBorderRadious),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 10, width: 60),
                SizedBox(height: 8),
                Skeleton(height: 14, width: 100),
                SizedBox(height: 4),
                Skeleton(height: 14, width: 80),
                SizedBox(height: 12),
                Skeleton(height: 16, width: 70, radious: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
