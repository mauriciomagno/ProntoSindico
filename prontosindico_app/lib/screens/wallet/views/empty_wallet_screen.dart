import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'components/wallet_balance_card.dart';

class EmptyWalletScreen extends StatelessWidget {
  const EmptyWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carteira"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: WalletBalanceCard(
                balance: 384.90,
                onTabChargeBalance: () {},
              ),
            ),
            const Spacer(flex: 2),
            Image.asset(
              Theme.of(context).brightness == Brightness.light
                  ? "assets/Illustration/EmptyState_lightTheme.png"
                  : "assets/Illustration/EmptyState_darkTheme.png",
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            const Spacer(),
            Text(
              "Nenhum histórico de transações",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5, vertical: defaultPadding),
              child: Text(
                "Ainda não há transações registradas. Assim que você fizer compras ou recarregar sua carteira, o histórico aparecerá aqui.",
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
