import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/domain/enums/user_role.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/providers/navigation_provider.dart';
import 'package:prontosindico/route/screen_export.dart';

class EntryPoint extends ConsumerStatefulWidget {
  const EntryPoint({super.key});

  @override
  ConsumerState<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends ConsumerState<EntryPoint> {
  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final role = userProfile?.role ?? UserRole.morador;
    final currentIndex = ref.watch(navigationProvider);

    // Define restricted areas
    final bool canAccessUsers =
        role == UserRole.administrador || role == UserRole.sindico;

    // Build lists dynamically
    final List<Widget> pages = [const HomeScreen()];
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.grid_view_outlined),
        activeIcon: Icon(Icons.grid_view),
        label: "INÍCIO",
      ),
    ];

    if (canAccessUsers) {
      pages.add(const AccessManagementScreen());
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.group_outlined),
        activeIcon: Icon(Icons.group),
        label: "USUÁRIOS",
      ));
    }

    //if (canAccessFinance) {
    pages.add(const FinancialReportScreen());
    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet_outlined),
      activeIcon: Icon(Icons.account_balance_wallet),
      label: "FINANCEIRO",
    ));
    //}

    // AVISOS is always visible to everyone
    pages.add(const MuralScreen());
    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.campaign_outlined),
      activeIcon: Icon(Icons.campaign),
      label: "AVISOS",
    ));

    // Safety check for index out of bounds if roles change
    int effectiveIndex = currentIndex;
    if (effectiveIndex >= pages.length) {
      effectiveIndex = 0;
      // We can't update state during build directly, but we can return 0.
    }

    return Scaffold(
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, animation, secondAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            child: child,
          );
        },
        child: pages[effectiveIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: effectiveIndex,
          onTap: (index) {
            ref.read(navigationProvider.notifier).state = index;
          },
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedItemColor: primaryColor,
          unselectedItemColor: blackColor20,
          items: items,
        ),
      ),
    );
  }
}
