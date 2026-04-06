import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../skelton.dart';

class SeconderyProductSkelton extends StatelessWidget {
  const SeconderyProductSkelton({
    super.key,
    this.isSmall = false,
    this.padding = const EdgeInsets.all(8),
  });

  final bool isSmall;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 8),
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      child: const Row(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Skeleton(radious: 0),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Skeleton(height: 10, width: 50),
                  SizedBox(height: 8),
                  Skeleton(height: 14, width: 120),
                  SizedBox(height: 4),
                  Skeleton(height: 14, width: 100),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Skeleton(height: 10, width: 10, radious: 2),
                      SizedBox(width: 4),
                      Skeleton(height: 10, width: 60),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
