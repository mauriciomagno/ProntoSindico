import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:prontosindico/constants.dart';

class FinancialReportScreen extends StatelessWidget {
  const FinancialReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLightColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
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
                'Relatorio Financeiro',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: grandisExtendedFont,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Visao geral das financas do Condominio Skyline.',
                style: TextStyle(fontSize: 14, color: blackColor40),
              ),
              SizedBox(height: 24),

              _buildSummaryDashboard(),
              SizedBox(height: 32),

              Text(
                'Transacoes Recentes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: blackColor80),
              ),
              SizedBox(height: 12),
              _buildTransactionItem(
                title: 'Manutencao de Elevadores',
                category: 'MANUTENCAO',
                amount: '- R\$ 4.200,00',
                date: '22 Out, 2023',
                isExpense: true,
              ),
              SizedBox(height: 12),
              _buildTransactionItem(
                title: 'Taxa Condominial: Unidade 42',
                category: 'RECEITA',
                amount: '+ R\$ 1.240,00',
                date: '21 Out, 2023',
                isExpense: false,
              ),
              SizedBox(height: 12),
              _buildTransactionItem(
                title: 'Servico de Limpeza Especial',
                category: 'SERVICOS',
                amount: '- R\$ 850,00',
                date: '19 Out, 2023',
                isExpense: true,
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
    );
  }

  Widget _buildSummaryDashboard() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildValueCard('Receita Bruta', 'R\$ 404.520', primaryColor, Icons.trending_up)),
            SizedBox(width: 12),
            Expanded(child: _buildValueCard('Despesas', 'R\$ 38.240', errorColor, Icons.trending_down)),
          ],
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 10, offset: Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SALDO EM CAIXA', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              SizedBox(height: 4),
              Text('R\$ 366.280,00', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Divider(color: Colors.white24),
              SizedBox(height: 8),
              Text('Atualizado ha 2 minutos', style: TextStyle(color: Colors.white60, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: blackColor10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: blackColor40)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String category,
    required String amount,
    required String date,
    required bool isExpense,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: blackColor10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isExpense ? errorColor : successColor).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpense ? Icons.remove_circle_outline : Icons.add_circle_outline,
              color: isExpense ? errorColor : successColor,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: blackColor80)),
                SizedBox(height: 4),
                Text('$category - $date', style: TextStyle(fontSize: 10, color: blackColor40)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isExpense ? errorColor : successColor,
            ),
          ),
        ],
      ),
    );
  }
}
