import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'components/payment_status_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: const PaymentStatusChart()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .moveY(begin: 20, end: 0),
            ),
          ],
        ),
      ),
    );
  }
}
