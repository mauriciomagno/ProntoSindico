import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:prontosindico/components/Banner/S/banner_s_style_1.dart';
import 'package:prontosindico/components/Banner/S/banner_s_style_5.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/route/screen_export.dart';

import 'components/best_sellers.dart';
import 'components/flash_sale.dart';
import 'components/most_popular.dart';
import 'components/offer_carousel_and_categories.dart';
import 'components/popular_products.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: const OffersCarouselAndCategories()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .moveY(begin: 20, end: 0),
            ),
            SliverToBoxAdapter(
              child: const PopularProducts()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .moveY(begin: 20, end: 0),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(
                child: const FlashSale()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .moveY(begin: 20, end: 0),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  BannerSStyle1(
                    title: "Novo Comunicado\n",
                    subtitle: "IMPORTANTE",
                    discountParcent: 0,
                    press: () {
                      Navigator.pushNamed(context, onSaleScreenRoute);
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .moveY(begin: 20, end: 0),
            ),
            SliverToBoxAdapter(
              child: const BestSellers()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .moveY(begin: 20, end: 0),
            ),
            SliverToBoxAdapter(
              child: const MostPopular()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 500.ms)
                  .moveY(begin: 20, end: 0),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),
                  BannerSStyle5(
                    title: "Assembleia\nVirtual",
                    subtitle: "Próxima Segunda",
                    bottomText: "PARTICIPAR",
                    press: () {
                      Navigator.pushNamed(context, onSaleScreenRoute);
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 600.ms)
                  .moveY(begin: 20, end: 0),
            ),
          ],
        ),
      ),
    );
  }
}
