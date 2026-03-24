import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:prontosindico/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLightColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: primaryColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset(
          'assets/logo/logo.png',
          height: 32,
          errorBuilder: (context, error, stackTrace) => Text("ProntoSindico", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: primaryColor),
            onPressed: () {},
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BEM-VINDO AO LAR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: blackColor40,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ola, Ricardo!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: grandisExtendedFont,
                ),
              ),
              Text(
                'Condominio Skyline',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                  fontFamily: grandisExtendedFont,
                ),
              ),
              SizedBox(height: 32),
              _buildReceiptCard(context),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meus Avisos',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: blackColor40),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('ver todos', style: TextStyle(fontSize: 12, color: primaryColor)),
                  ),
                ],
              ),
              SizedBox(height: 8),
              _buildRecentNotice(
                context,
                title: '03 Recentes',
                subtitle: 'Ultima ha 2 horas',
                icon: Icons.notifications_active,
                color: errorColor,
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: blackColor10),
      ),
      child: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROXIMO RECIBO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: blackColor40)),
                    SizedBox(height: 4),
                    Text('R\$ 1.240,00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                    Text('Vence em 10 Mai', style: TextStyle(fontSize: 12, color: blackColor40)),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: secondaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('PENDENTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: secondaryColor)),
                ),
              ],
            ),
            SizedBox(height: 24),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: CircularProgressIndicator(
                      value: 0.82,
                      strokeWidth: 12,
                      backgroundColor: blackColor10,
                      color: primaryColor,
                    ),
                  ),
                  Text('82%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text('Condominio Pago no Mes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: blackColor60)),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            _buildAmountRow('Pago', 'R\$ 382.400,00', primaryColor),
            SizedBox(height: 8),
            _buildAmountRow('Pendente', 'R\$ 22.120,00', secondaryColor),
            SizedBox(height: 8),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Arrecadado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: blackColor40)),
                Text('R\$ 404.520,00', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, String amount, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: blackColor60)),
        Spacer(),
        Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: blackColor80)),
      ],
    );
  }

  Widget _buildRecentNotice(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: blackColor10)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: blackColor80)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: blackColor40)),
            ],
          ),
          Spacer(),
          Icon(Icons.chevron_right, color: blackColor20),
        ],
      ),
    );
  }
}
