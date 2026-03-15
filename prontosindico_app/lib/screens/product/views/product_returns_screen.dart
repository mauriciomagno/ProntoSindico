import 'package:flutter/material.dart';

import '../../../constants.dart';

class ProductReturnsScreen extends StatelessWidget {
  const ProductReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: defaultPadding),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 40,
                    child: BackButton(),
                  ),
                  Text(
                    "Devolução",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: Text(
                "Devoluções e trocas pré-pagas gratuitas para pedidos enviados. Receba reembolso mais rápido com devoluções online fáceis. Devolva ou troque mercadorias não utilizadas ou defeituosas por correio ou em uma das nossas lojas. Itens sob encomenda não podem ser cancelados, trocados ou devolvidos.",
              ),
            )
          ],
        ),
      ),
    );
  }
}
